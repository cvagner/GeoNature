"""
Filter the query of synthese using SQLA expression language and 'select' object 
https://docs.sqlalchemy.org/en/latest/core/tutorial.html#selecting
Not returning model object but tuple, but much more efficiebt
"""
from flask import current_app, request
from sqlalchemy import func, or_, and_, select, join
from sqlalchemy.orm import aliased
from shapely.wkt import loads
from geoalchemy2.shape import from_shape

from geonature.utils.env import DB
from geonature.utils.utilsgeometry import circle_from_point
from geonature.core.taxonomie.models import Taxref, CorTaxonAttribut, TaxrefLR
from geonature.core.gn_synthese.models import (
    Synthese,
    CorObserverSynthese,
    TSources,
    CorAreaSynthese,
    VSyntheseForWebApp,
)
from geonature.core.gn_meta.models import TAcquisitionFramework, CorDatasetActor


class SyntheseQuery:
    """
        class for building synthese query
    """

    def __init__(self, query, filters):
        self.query = query
        self.filters = filters
        self.first = True
        self._already_joined_table = []
        self.query_joins = None

    def add_join(self, right_table, right_column, left_column):
        if self.first:
            self.query_joins = VSyntheseForWebApp.__table__.join(
                right_table, left_column == right_column
            )
            self.first = False
            self._already_joined_table.append(right_table)
        else:
            # check if the table not already joined
            if right_table not in self._already_joined_table:
                self.query_joins = self.query_joins.join(
                    right_table, left_column == right_column
                )
                # push the joined table in _already_joined_table list
                self._already_joined_table.append(right_table)

    def add_join_multiple_cond(self, right_table, conditions):
        if self.first:
            self.query_joins = VSyntheseForWebApp.__table__.join(
                right_table, and_(*conditions)
            )
            self.first = False
        else:
            # check if the table not already joined
            if right_table not in self._already_joined_table:
                self.query_joins = self.query_joins.join(right_table, and_(*conditions))
                # push the joined table in _already_joined_table list
                self._already_joined_table.append(right_table)

    def filter_query_with_cruved(self, user, allowed_datasets):
        """
        Filter the query with the cruved authorization of a user
        """
        if user.value_filter in ("1", "2"):
            self.add_join(
                CorObserverSynthese,
                CorObserverSynthese.id_synthese,
                VSyntheseForWebApp.id_synthese,
            )

            ors_filters = [
                CorObserverSynthese.id_role == user.id_role,
                VSyntheseForWebApp.id_digitiser == user.id_role,
            ]
            if current_app.config["SYNTHESE"]["CRUVED_SEARCH_WITH_OBSERVER_AS_TXT"]:
                user_fullname1 = user.nom_role + " " + user.prenom_role + "%"
                user_fullname2 = user.prenom_role + " " + user.nom_role + "%"
                ors_filters.append(VSyntheseForWebApp.observers.ilike(user_fullname1))
                ors_filters.append(VSyntheseForWebApp.observers.ilike(user_fullname2))

            if user.value_filter == "1":
                self.query = self.query.where(or_(*ors_filters))
            elif user.value_filter == "2":
                ors_filters.append(VSyntheseForWebApp.id_dataset.in_(allowed_datasets))
                self.query = self.query.where(or_(*ors_filters))

    def filter_taxonomy(self):
        """
        Filters the query with taxonomic attributes
        Parameters:
            - q (SQLAchemyQuery): an SQLAchemy query
            - filters (dict): a dict of filter
        Returns:
            -Tuple: the SQLAlchemy query and the filter dictionnary
        """
        if "cd_ref" in self.filters:
            sub_query_synonym = select([Taxref.cd_nom]).where(
                Taxref.cd_ref.in_(self.filters.pop("cd_ref"))
            )
            self.query = self.query.where(
                VSyntheseForWebApp.cd_nom.in_(sub_query_synonym)
            )
        if "taxonomy_group2_inpn" in self.filters:
            self.add_join(Taxref, Taxref.cd_nom, VSyntheseForWebApp.cd_nom)
            self.query = self.query.where(
                Taxref.group2_inpn.in_(self.filters.pop("taxonomy_group2_inpn"))
            )

        if "taxonomy_id_hab" in self.filters:
            self.add_join(Taxref, Taxref.cd_nom, VSyntheseForWebApp.cd_nom)
            self.query = self.query.where(
                Taxref.id_habitat.in_(self.filters.pop("taxonomy_id_hab"))
            )

        if "taxonomy_lr" in self.filters:
            sub_query_lr = select([TaxrefLR.cd_nom]).where(
                TaxrefLR.id_categorie_france.in_(self.filters.pop("taxonomy_lr"))
            )
            # TODO est-ce qu'il faut pas filtrer sur le cd_ ref ?
            # quid des protection définit à rang superieur de la saisie ?
            self.query = self.query.where(VSyntheseForWebApp.cd_nom.in_(sub_query_lr))

        aliased_cor_taxon_attr = {}
        for colname, value in self.filters.items():
            if colname.startswith("taxhub_attribut"):
                self.add_join(Taxref, Taxref.cd_nom, VSyntheseForWebApp.cd_nom)
                taxhub_id_attr = colname[16:]
                aliased_cor_taxon_attr[taxhub_id_attr] = aliased(CorTaxonAttribut)
                self.add_join_multiple_cond(
                    aliased_cor_taxon_attr[taxhub_id_attr],
                    [
                        aliased_cor_taxon_attr[taxhub_id_attr].id_attribut
                        == taxhub_id_attr,
                        aliased_cor_taxon_attr[taxhub_id_attr].cd_ref
                        == func.taxonomie.find_cdref(VSyntheseForWebApp.cd_nom),
                    ],
                )
                self.query = self.query.where(
                    aliased_cor_taxon_attr[taxhub_id_attr].valeur_attribut.in_(value)
                )

        # remove attributes taxhub from filters
        self.filters = {
            colname: value
            for colname, value in self.filters.items()
            if not colname.startswith("taxhub_attribut")
        }

    def filter_other_filters(self):
        """
            Other filters
        """
        if "id_dataset" in self.filters:
            self.query = self.query.where(
                VSyntheseForWebApp.id_dataset.in_(self.filters.pop("id_dataset"))
            )
        if "observers" in self.filters:
            self.query = self.query.where(
                VSyntheseForWebApp.observers.ilike(
                    "%" + self.filters.pop("observers")[0] + "%"
                )
            )

        if "id_organism" in self.filters:
            self.add_join(
                CorDatasetActor,
                CorDatasetActor.id_dataset,
                VSyntheseForWebApp.id_dataset,
            )
            self.query = self.query.where(
                CorDatasetActor.id_organism.in_(self.filters.pop("id_organism"))
            )

        if "date_min" in self.filters:
            self.query = self.query.where(
                VSyntheseForWebApp.date_min >= self.filters.pop("date_min")[0]
            )

        if "date_max" in self.filters:
            self.query = self.query.where(
                VSyntheseForWebApp.date_min <= self.filters.pop("date_max")[0]
            )

        if "id_acquisition_framework" in self.filters:
            self.query = self.query.where(
                VSyntheseForWebApp.id_acquisition_framework.in_(
                    self.filters.pop("id_acquisition_framework")
                )
            )

        if "geoIntersection" in self.filters:
            # Insersect with the geom send from the map
            ors = []
            for str_wkt in self.filters["geoIntersection"]:
                # if the geom is a circle
                if "radius" in self.filters:
                    radius = self.filters.pop("radius")[0]
                    wkt = loads(str_wkt)
                    wkt = circle_from_point(wkt, float(radius))
                else:
                    wkt = loads(str_wkt)
                geom_wkb = from_shape(wkt, srid=4326)
                ors.append(VSyntheseForWebApp.the_geom_4326.ST_Intersects(geom_wkb))

            self.query = self.query.where(or_(*ors))
            self.filters.pop("geoIntersection")

        if "period_start" in self.filters and "period_end" in self.filters:
            period_start = self.filters.pop("period_start")[0]
            period_end = self.filters.pop("period_end")[0]
            self.query = self.query.where(
                or_(
                    func.gn_commons.is_in_period(
                        func.date(VSyntheseForWebApp.date_min),
                        func.to_date(period_start, "DD-MM"),
                        func.to_date(period_end, "DD-MM"),
                    ),
                    func.gn_commons.is_in_period(
                        func.date(VSyntheseForWebApp.date_max),
                        func.to_date(period_start, "DD-MM"),
                        func.to_date(period_end, "DD-MM"),
                    ),
                )
            )

        # generic filters
        for colname, value in self.filters.items():
            if colname.startswith("area"):
                self.add_join(
                    CorAreaSynthese,
                    CorAreaSynthese.id_synthese,
                    VSyntheseForWebApp.id_synthese,
                )
                self.query = self.query.where(CorAreaSynthese.id_area.in_(value))
            else:
                col = getattr(VSyntheseForWebApp.__table__.columns, colname)
                self.query = self.query.where(col.in_(value))
