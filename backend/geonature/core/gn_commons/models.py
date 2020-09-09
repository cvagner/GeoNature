"""
    Modèles du schéma gn_commons
"""

from sqlalchemy import ForeignKey
from sqlalchemy.sql import select, func
from sqlalchemy.dialects.postgresql import UUID
from geoalchemy2 import Geometry

import os

from flask import current_app

from pypnnomenclature.models import TNomenclatures
from pypnusershub.db.models import User
from utils_flask_sqla.serializers import serializable
from utils_flask_sqla_geo.serializers import geoserializable

from geonature.utils.env import DB
from geonature.core.gn_commons.file_manager import rename_file

# from geonature.core.gn_meta.models import TDatasets


@serializable
class BibTablesLocation(DB.Model):
    __tablename__ = "bib_tables_location"
    __table_args__ = {"schema": "gn_commons"}
    id_table_location = DB.Column(DB.Integer, primary_key=True)
    table_desc = DB.Column(DB.Unicode)
    schema_name = DB.Column(DB.Unicode)
    table_name = DB.Column(DB.Unicode)
    pk_field = DB.Column(DB.Unicode)
    uuid_field_name = DB.Column(DB.Unicode)


cor_module_dataset = DB.Table(
    "cor_module_dataset",
    DB.Column(
        "id_module",
        DB.Integer,
        ForeignKey("gn_commons.t_modules.id_module"),
        primary_key=True,
    ),
    DB.Column(
        "id_dataset",
        DB.Integer,
        ForeignKey("gn_meta.t_datasets.id_dataset"),
        primary_key=True,
    ),
    schema="gn_commons",
)


@serializable
class TModules(DB.Model):
    __tablename__ = "t_modules"
    __table_args__ = {"schema": "gn_commons"}
    id_module = DB.Column(DB.Integer, primary_key=True)
    module_code = DB.Column(DB.Unicode)
    module_label = DB.Column(DB.Unicode)
    module_picto = DB.Column(DB.Unicode)
    module_desc = DB.Column(DB.Unicode)
    module_group = DB.Column(DB.Unicode)
    module_path = DB.Column(DB.Unicode)
    module_external_url = DB.Column(DB.Unicode)
    module_target = DB.Column(DB.Unicode)
    module_comment = DB.Column(DB.Unicode)
    active_frontend = DB.Column(DB.Boolean)
    active_backend = DB.Column(DB.Boolean)
    module_doc_url = DB.Column(DB.Unicode)
    module_order = DB.Column(DB.Integer)


@serializable
class TMedias(DB.Model):
    __tablename__ = "t_medias"
    __table_args__ = {"schema": "gn_commons"}
    id_media = DB.Column(DB.Integer, primary_key=True)
    id_nomenclature_media_type = DB.Column(
        DB.Integer
        # ,
        # ForeignKey('ref_nomenclatures.t_nomenclatures.id_nomenclature')
    )
    id_table_location = DB.Column(
        DB.Integer, ForeignKey("gn_commons.bib_tables_location.id_table_location")
    )
    unique_id_media = DB.Column(
        UUID(as_uuid=True), default=select([func.uuid_generate_v4()])
    )
    uuid_attached_row = DB.Column(UUID(as_uuid=True))
    title_fr = DB.Column(DB.Unicode)
    title_en = DB.Column(DB.Unicode)
    title_it = DB.Column(DB.Unicode)
    title_es = DB.Column(DB.Unicode)
    title_de = DB.Column(DB.Unicode)
    media_url = DB.Column(DB.Unicode)
    media_path = DB.Column(DB.Unicode)
    author = DB.Column(DB.Unicode)
    description_fr = DB.Column(DB.Unicode)
    description_en = DB.Column(DB.Unicode)
    description_it = DB.Column(DB.Unicode)
    description_es = DB.Column(DB.Unicode)
    description_de = DB.Column(DB.Unicode)
    is_public = DB.Column(DB.Boolean, default=True)
    meta_create_date = DB.Column(DB.DateTime)
    meta_update_date = DB.Column(DB.DateTime)

    def __before_commit_delete__(self):
        # déclenché sur un DELETE : on supprime le fichier
        if self.media_path and os.path.exists(
            os.path.join(current_app.config["BASE_DIR"] + "/" + self.media_path)
        ):
            # delete file
            self.remove_file()
            # delete thumbnail
            self.remove_thumbnails()

    def remove_file(self):
        initial_path = self.media_path
        (inv_file_name, inv_file_path) = initial_path[::-1].split("/", 1)
        file_name = inv_file_name[::-1]
        file_path = inv_file_path[::-1]

        try:
            self.media_path = rename_file(
                self.media_path, "{}/deleted_{}".format(file_path, file_name)
            )
        except FileNotFoundError:
            raise Exception("Unable to delete file {}".format(initial_path))

    def remove_thumbnails(self):
        # delete thumbnail test sur nom des fichiers avec id dans le dossier thumbnail
        dir_thumbnail = os.path.join(
            current_app.config["BASE_DIR"],
            current_app.config["UPLOAD_FOLDER"],
            "thumbnails",
            str(self.id_table_location),
        )
        for f in os.listdir(dir_thumbnail):
            if f.split("_")[0] == str(self.id_media):
                abs_path = os.path.join(dir_thumbnail, f)
                os.path.exists(abs_path) and os.remove(abs_path)


@serializable
class TParameters(DB.Model):
    __tablename__ = "t_parameters"
    __table_args__ = {"schema": "gn_commons"}
    id_parameter = DB.Column(DB.Integer, primary_key=True)
    id_organism = DB.Column(
        DB.Integer, ForeignKey("utilisateurs.bib_organismes.id_organisme")
    )
    parameter_name = DB.Column(DB.Unicode)
    parameter_desc = DB.Column(DB.Unicode)
    parameter_value = DB.Column(DB.Unicode)
    parameter_extra_value = DB.Column(DB.Unicode)


@serializable
class TValidations(DB.Model):
    __tablename__ = "t_validations"
    __table_args__ = {"schema": "gn_commons"}

    id_validation = DB.Column(DB.Integer, primary_key=True)
    uuid_attached_row = DB.Column(UUID(as_uuid=True))
    id_nomenclature_valid_status = DB.Column(DB.Integer)
    id_validator = DB.Column(DB.Integer)
    validation_auto = DB.Column(DB.Boolean)
    validation_comment = DB.Column(DB.Unicode)
    validation_date = DB.Column(DB.DateTime)
    validation_auto = DB.Column(DB.Boolean)
    validation_label = DB.relationship(
        TNomenclatures,
        primaryjoin=(TNomenclatures.id_nomenclature == id_nomenclature_valid_status),
        foreign_keys=[id_nomenclature_valid_status],
    )
    validator_role = DB.relationship(
        User, primaryjoin=(User.id_role == id_validator), foreign_keys=[id_validator]
    )

    def __init__(
        self,
        uuid_attached_row,
        id_nomenclature_valid_status,
        id_validator,
        validation_comment,
        validation_date,
        validation_auto,
    ):
        self.uuid_attached_row = uuid_attached_row
        self.id_nomenclature_valid_status = id_nomenclature_valid_status
        self.id_validator = id_validator
        self.validation_comment = validation_comment
        self.validation_date = validation_date
        self.validation_auto = validation_auto


@serializable
@geoserializable
class VLatestValidations(DB.Model):
    __tablename__ = "v_latest_validation"
    __table_args__ = {"schema": "gn_commons"}
    id_validation = DB.Column(DB.Integer, primary_key=True)
    uuid_attached_row = DB.Column(UUID(as_uuid=True))
    id_nomenclature_valid_status = DB.Column(DB.Integer)
    id_validator = DB.Column(DB.Integer)
    validation_comment = DB.Column(DB.Unicode)
    validation_date = DB.Column(DB.DateTime)


@serializable
class THistoryActions(DB.Model):
    __tablename__ = "t_history_actions"
    __table_args__ = {"schema": "gn_commons"}

    id_history_action = DB.Column(DB.Integer, primary_key=True)
    id_table_location = DB.Column(DB.Integer)
    uuid_attached_row = DB.Column(UUID(as_uuid=True))
    operation_type = DB.Column(DB.Unicode)
    operation_date = DB.Column(DB.DateTime)
    table_content = DB.Column(DB.Unicode)


@serializable
class TMobileApps(DB.Model):
    __tablename__ = "t_mobile_apps"
    __table_args__ = {"schema": "gn_commons"}
    id_mobile_app = DB.Column(DB.Integer, primary_key=True)
    app_code = DB.Column(DB.Unicode)
    relative_path_apk = DB.Column(DB.Unicode)
    url_apk = DB.Column(DB.Unicode)
    package = DB.Column(DB.Unicode)
    version_code = DB.Column(DB.Unicode)
