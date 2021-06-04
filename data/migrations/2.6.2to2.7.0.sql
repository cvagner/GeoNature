-- Update script from GeoNature 2.6.2 to 2.7.0

BEGIN;

-------------
-- VARIOUS --
-------------

-- REF_GEO - Add missing unique contraints
CREATE UNIQUE INDEX IF NOT EXISTS i_unique_l_areas_id_type_area_code ON ref_geo.l_areas (id_type, area_code);
ALTER TABLE ONLY ref_geo.l_areas DROP CONSTRAINT IF EXISTS unique_l_areas_id_type_area_code;
ALTER TABLE ONLY ref_geo.l_areas
     ADD CONSTRAINT  unique_l_areas_id_type_area_code UNIQUE (id_type, area_code);
CREATE UNIQUE INDEX IF NOT EXISTS  i_unique_bib_areas_types_type_code ON ref_geo.bib_areas_types(type_code);
ALTER TABLE ONLY ref_geo.bib_areas_types DROP CONSTRAINT IF EXISTS unique_bib_areas_types_type_code;
ALTER TABLE ONLY ref_geo.bib_areas_types
     ADD CONSTRAINT unique_bib_areas_types_type_code UNIQUE (type_code);
    
-- !!! TODO !!! A ne faire que si le paramètre n'existe pas déjà dans la table...
-- Oubli de la 2.6.0 - A faire seulement sur une nouvelle installation faite avec la 2.6.0, 2.6.1 ou 2.6.2
-- où il manquait ce paramètre fait en update2.5.5to2.6.0
INSERT INTO gn_commons.t_parameters
(id_organism, parameter_name, parameter_desc, parameter_value, parameter_extra_value)
VALUES(0, 'ref_sensi_version', 'Version du referentiel de sensibilité', 'Referentiel de sensibilite taxref v13 2020', '');

-- Ajout de contraintes d'unicité sur les permissions
ALTER TABLE gn_permissions.cor_object_module ADD CONSTRAINT unique_cor_object_module UNIQUE (id_object,id_module);
ALTER TABLE gn_permissions.t_objects ADD CONSTRAINT unique_t_objects UNIQUE (code_object);

-- Ajout de champs à la table t_modules
ALTER TABLE gn_commons.t_modules ADD type CHARACTER VARYING(255);  -- polymorphisme
ALTER TABLE gn_commons.t_modules ADD meta_create_date timestamp without time zone DEFAULT now();
ALTER TABLE gn_commons.t_modules ADD meta_update_date timestamp without time zone DEFAULT now();
CREATE TRIGGER tri_meta_dates_change_t_modules
      BEFORE INSERT OR UPDATE
      ON gn_commons.t_modules
      FOR EACH ROW
      EXECUTE PROCEDURE public.fct_trg_meta_dates_change();

-- Datasets - Ajout d'un champs pour lier un JDD à une liste de taxons
ALTER TABLE gn_meta.t_datasets 
    ADD COLUMN id_taxa_list integer;
COMMENT ON COLUMN gn_meta.t_datasets.id_taxa_list IS 'Identifiant de la liste de taxon associé au JDD. FK: taxonomie.bib_liste';

ALTER TABLE ONLY gn_meta.t_datasets
    ADD CONSTRAINT fk_t_datasets_id_taxa_list FOREIGN KEY (id_taxa_list) REFERENCES taxonomie.bib_listes ON UPDATE CASCADE;

--------------------------------------------
-- METADATA - DELETE CASCADE ON DS AND AF --
--------------------------------------------

-- cor module dataset
ALTER TABLE gn_commons.cor_module_dataset 
    DROP constraint fk_cor_module_dataset_id_module;
ALTER TABLE gn_commons.cor_module_dataset 
    DROP constraint fk_cor_module_dataset_id_dataset;

ALTER TABLE gn_commons.cor_module_dataset 
    ADD constraint fk_cor_module_dataset_id_dataset FOREIGN KEY (id_dataset) REFERENCES gn_meta.t_datasets(id_dataset) ON UPDATE cascade on delete cascade,
    ADD constraint fk_cor_module_dataset_id_module FOREIGN KEY (id_module) REFERENCES gn_commons.t_modules(id_module) ON UPDATE cascade on delete cascade;

-- cor dataset actor
ALTER TABLE ONLY gn_meta.cor_dataset_actor
    DROP constraint fk_cor_dataset_actor_id_dataset;
ALTER TABLE ONLY gn_meta.cor_dataset_actor
    DROP constraint fk_dataset_actor_id_role;

ALTER TABLE ONLY gn_meta.cor_dataset_actor
    ADD CONSTRAINT fk_cor_dataset_actor_id_dataset FOREIGN KEY (id_dataset)
     REFERENCES gn_meta.t_datasets(id_dataset) ON UPDATE CASCADE ON DELETE CASCADE,
    ADD CONSTRAINT fk_dataset_actor_id_role FOREIGN KEY (id_role) 
     REFERENCES utilisateurs.t_roles(id_role) ON UPDATE CASCADE ON DELETE CASCADE;

-- territory
ALTER TABLE ONLY gn_meta.cor_dataset_territory
    DROP constraint fk_cor_dataset_territory_id_dataset;
ALTER TABLE ONLY gn_meta.cor_dataset_protocol
    ADD CONSTRAINT fk_cor_dataset_territory_id_dataset FOREIGN KEY (id_dataset) 
    REFERENCES gn_meta.t_datasets(id_dataset) ON UPDATE CASCADE ON DELETE CASCADE;

-- protocol
ALTER TABLE ONLY gn_meta.cor_dataset_protocol
    DROP constraint fk_cor_dataset_protocol_id_dataset;
ALTER TABLE ONLY gn_meta.cor_dataset_protocol
    ADD CONSTRAINT fk_cor_dataset_protocol_id_dataset FOREIGN KEY (id_dataset) 
    REFERENCES gn_meta.t_datasets(id_dataset) ON UPDATE CASCADE ON DELETE CASCADE;

-- AF
ALTER TABLE ONLY gn_meta.cor_acquisition_framework_objectif
    DROP constraint fk_cor_acquisition_framework_objectif_id_acquisition_framework;
ALTER TABLE ONLY gn_meta.cor_acquisition_framework_objectif
    ADD CONSTRAINT fk_cor_acquisition_framework_objectif_id_acquisition_framework FOREIGN KEY (id_acquisition_framework) 
    REFERENCES gn_meta.t_acquisition_frameworks(id_acquisition_framework) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY gn_meta.cor_acquisition_framework_actor
    DROP constraint fk_cor_acquisition_framework_actor_id_acquisition_framework;
ALTER TABLE ONLY gn_meta.cor_acquisition_framework_actor
    ADD CONSTRAINT fk_cor_acquisition_framework_actor_id_acquisition_framework FOREIGN KEY (id_acquisition_framework) 
    REFERENCES gn_meta.t_acquisition_frameworks(id_acquisition_framework) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY gn_meta.cor_acquisition_framework_actor
drop  constraint fk_cor_acquisition_framework_actor_id_role;
ALTER TABLE ONLY gn_meta.cor_acquisition_framework_actor
    ADD CONSTRAINT fk_cor_acquisition_framework_actor_id_role FOREIGN KEY (id_role) 
    REFERENCES utilisateurs.t_roles(id_role) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY gn_meta.cor_acquisition_framework_actor
    DROP constraint fk_cor_acquisition_framework_actor_id_organism;
ALTER TABLE ONLY gn_meta.cor_acquisition_framework_actor
    ADD CONSTRAINT fk_cor_acquisition_framework_actor_id_organism FOREIGN KEY (id_organism) 
    REFERENCES utilisateurs.bib_organismes(id_organisme) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY gn_meta.cor_acquisition_framework_voletsinp
    DROP constraint fk_cor_acquisition_framework_voletsinp_id_acquisition_framework;
ALTER TABLE ONLY gn_meta.cor_acquisition_framework_voletsinp
    ADD CONSTRAINT fk_cor_acquisition_framework_voletsinp_id_acquisition_framework FOREIGN KEY (id_acquisition_framework) 
    REFERENCES gn_meta.t_acquisition_frameworks(id_acquisition_framework) ON UPDATE CASCADE ON DELETE NO ACTION;

ALTER TABLE ONLY gn_meta.cor_acquisition_framework_publication
    DROP constraint fk_cor_acquisition_framework_publication_id_publication;
ALTER TABLE ONLY gn_meta.cor_acquisition_framework_publication
    ADD CONSTRAINT fk_cor_acquisition_framework_publication_id_publication FOREIGN KEY (id_acquisition_framework) 
    REFERENCES gn_meta.t_acquisition_frameworks(id_acquisition_framework) ON UPDATE CASCADE ON DELETE CASCADE;

---------------------------------------
-- OCCTAX - ADDITIONAL FIELDS & DATA --
---------------------------------------

-- Ajout des tables pour les données additionnels dans Occtax
ALTER TABLE pr_occtax.t_releves_occtax
    ADD COLUMN additional_fields jsonb;
	
ALTER TABLE pr_occtax.t_occurrences_occtax
    ADD COLUMN additional_fields jsonb;
	
ALTER TABLE pr_occtax.cor_counting_occtax
    ADD COLUMN additional_fields jsonb;

-- Révision de la fonction insérant les données d'Occtax vers la synthèse, pour y ajouter les champs additionnels
CREATE OR REPLACE FUNCTION pr_occtax.insert_in_synthese(my_id_counting integer)
    RETURNS integer[]
AS $BODY$  DECLARE
  new_count RECORD;
  occurrence RECORD;
  releve RECORD;
  id_source integer;
  id_module integer;
  id_nomenclature_source_status integer;
  myobservers RECORD;
  id_role_loop integer;

  BEGIN
  --recupération du counting à partir de son ID
  SELECT INTO new_count * FROM pr_occtax.cor_counting_occtax WHERE id_counting_occtax = my_id_counting;

  -- Récupération de l'occurrence
  SELECT INTO occurrence * FROM pr_occtax.t_occurrences_occtax occ WHERE occ.id_occurrence_occtax = new_count.id_occurrence_occtax;

  -- Récupération du relevé
  SELECT INTO releve * FROM pr_occtax.t_releves_occtax rel WHERE occurrence.id_releve_occtax = rel.id_releve_occtax;

  -- Récupération de la source
  SELECT INTO id_source s.id_source FROM gn_synthese.t_sources s WHERE name_source ILIKE 'occtax';

  -- Récupération de l'id_module
  SELECT INTO id_module gn_commons.get_id_module_bycode('OCCTAX');

  -- Récupération du status_source depuis le JDD
  SELECT INTO id_nomenclature_source_status d.id_nomenclature_source_status FROM gn_meta.t_datasets d WHERE id_dataset = releve.id_dataset;

  --Récupération et formatage des observateurs
  SELECT INTO myobservers array_to_string(array_agg(rol.nom_role || ' ' || rol.prenom_role), ', ') AS observers_name,
  array_agg(rol.id_role) AS observers_id
  FROM pr_occtax.cor_role_releves_occtax cor
  JOIN utilisateurs.t_roles rol ON rol.id_role = cor.id_role
  WHERE cor.id_releve_occtax = releve.id_releve_occtax;

  -- insertion dans la synthese
  INSERT INTO gn_synthese.synthese (
  unique_id_sinp,
  unique_id_sinp_grp,
  id_source,
  entity_source_pk_value,
  id_dataset,
  id_module,
  id_nomenclature_geo_object_nature,
  id_nomenclature_grp_typ,
  grp_method,
  id_nomenclature_obs_technique,
  id_nomenclature_bio_status,
  id_nomenclature_bio_condition,
  id_nomenclature_naturalness,
  id_nomenclature_exist_proof,
  id_nomenclature_diffusion_level,
  id_nomenclature_life_stage,
  id_nomenclature_sex,
  id_nomenclature_obj_count,
  id_nomenclature_type_count,
  id_nomenclature_observation_status,
  id_nomenclature_blurring,
  id_nomenclature_source_status,
  id_nomenclature_info_geo_type,
  id_nomenclature_behaviour,
  count_min,
  count_max,
  cd_nom,
  cd_hab,
  nom_cite,
  meta_v_taxref,
  sample_number_proof,
  digital_proof,
  non_digital_proof,
  altitude_min,
  altitude_max,
  depth_min,
  depth_max,
  place_name,
  precision,
  the_geom_4326,
  the_geom_point,
  the_geom_local,
  date_min,
  date_max,
  observers,
  determiner,
  id_digitiser,
  id_nomenclature_determination_method,
  comment_context,
  comment_description,
  last_action,
	--CHAMPS ADDITIONNELS OCCTAX
  additional_data
  )
  VALUES(
    new_count.unique_id_sinp_occtax,
    releve.unique_id_sinp_grp,
    id_source,
    new_count.id_counting_occtax,
    releve.id_dataset,
    id_module,
    releve.id_nomenclature_geo_object_nature,
    releve.id_nomenclature_grp_typ,
    releve.grp_method,
    occurrence.id_nomenclature_obs_technique,
    occurrence.id_nomenclature_bio_status,
    occurrence.id_nomenclature_bio_condition,
    occurrence.id_nomenclature_naturalness,
    occurrence.id_nomenclature_exist_proof,
    occurrence.id_nomenclature_diffusion_level,
    new_count.id_nomenclature_life_stage,
    new_count.id_nomenclature_sex,
    new_count.id_nomenclature_obj_count,
    new_count.id_nomenclature_type_count,
    occurrence.id_nomenclature_observation_status,
    occurrence.id_nomenclature_blurring,
    -- status_source récupéré depuis le JDD
    id_nomenclature_source_status,
    -- id_nomenclature_info_geo_type: type de rattachement = non saisissable: georeferencement
    ref_nomenclatures.get_id_nomenclature('TYP_INF_GEO', '1'),
    occurrence.id_nomenclature_behaviour,
    new_count.count_min,
    new_count.count_max,
    occurrence.cd_nom,
    releve.cd_hab,
    occurrence.nom_cite,
    occurrence.meta_v_taxref,
    occurrence.sample_number_proof,
    occurrence.digital_proof,
    occurrence.non_digital_proof,
    releve.altitude_min,
    releve.altitude_max,
    releve.depth_min,
    releve.depth_max,
    releve.place_name,
    releve.precision,
    releve.geom_4326,
    ST_CENTROID(releve.geom_4326),
    releve.geom_local,
    date_trunc('day',releve.date_min)+COALESCE(releve.hour_min,'00:00:00'::time),
    date_trunc('day',releve.date_max)+COALESCE(releve.hour_max,'00:00:00'::time),
    COALESCE (myobservers.observers_name, releve.observers_txt),
    occurrence.determiner,
    releve.id_digitiser,
    occurrence.id_nomenclature_determination_method,
    releve.comment,
    occurrence.comment,
    'I',
	  --CHAMPS ADDITIONNELS OCCTAX
	  new_count.additional_fields || occurrence.additional_fields || releve.additional_fields
  );

    RETURN myobservers.observers_id ;
  END;
  $BODY$
    LANGUAGE plpgsql VOLATILE
  COST 100;

-- Révision de la fonction mettant à jour les données d'Occtax vers la synthèse, pour y ajouter les champs additionnels
CREATE OR REPLACE FUNCTION pr_occtax.fct_tri_synthese_update_counting()
  RETURNS trigger
  LANGUAGE 'plpgsql'
  VOLATILE
  COST 100
AS $BODY$DECLARE
  occurrence RECORD;
  releve RECORD;
BEGIN

  -- Récupération de l'occurrence
  SELECT INTO occurrence * FROM pr_occtax.t_occurrences_occtax occ WHERE occ.id_occurrence_occtax = NEW.id_occurrence_occtax;
  -- Récupération du relevé
  SELECT INTO releve * FROM pr_occtax.t_releves_occtax rel WHERE occurrence.id_releve_occtax = rel.id_releve_occtax;
  
-- Update dans la synthese
  UPDATE gn_synthese.synthese
  SET
  entity_source_pk_value = NEW.id_counting_occtax,
  id_nomenclature_life_stage = NEW.id_nomenclature_life_stage,
  id_nomenclature_sex = NEW.id_nomenclature_sex,
  id_nomenclature_obj_count = NEW.id_nomenclature_obj_count,
  id_nomenclature_type_count = NEW.id_nomenclature_type_count,
  count_min = NEW.count_min,
  count_max = NEW.count_max,
  last_action = 'U',
  --CHAMPS ADDITIONNELS OCCTAX
  additional_data = NEW.additional_fields || occurrence.additional_fields || releve.additional_fields
  WHERE unique_id_sinp = NEW.unique_id_sinp_occtax;
  IF(NEW.unique_id_sinp_occtax <> OLD.unique_id_sinp_occtax) THEN
      RAISE EXCEPTION 'ATTENTION : %', 'Le champ "unique_id_sinp_occtax" est généré par GeoNature et ne doit pas être changé.'
          || chr(10) || 'Il est utilisé par le SINP pour identifier de manière unique une observation.'
          || chr(10) || 'Si vous le changez, le SINP considérera cette observation comme une nouvelle observation.'
          || chr(10) || 'Si vous souhaitez vraiment le changer, désactivez ce trigger, faite le changement, réactiez ce trigger'
          || chr(10) || 'ET répercutez manuellement les changements dans "gn_synthese.synthese".';
  END IF;
  RETURN NULL;
END;
$BODY$;

CREATE OR REPLACE FUNCTION pr_occtax.fct_tri_synthese_update_occ()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    VOLATILE
    COST 100
AS $BODY$  DECLARE
  BEGIN
    UPDATE gn_synthese.synthese SET
      id_nomenclature_obs_technique = NEW.id_nomenclature_obs_technique,
      id_nomenclature_bio_condition = NEW.id_nomenclature_bio_condition,
      id_nomenclature_bio_status = NEW.id_nomenclature_bio_status,
      id_nomenclature_naturalness = NEW.id_nomenclature_naturalness,
      id_nomenclature_exist_proof = NEW.id_nomenclature_exist_proof,
      id_nomenclature_diffusion_level = NEW.id_nomenclature_diffusion_level,
      id_nomenclature_observation_status = NEW.id_nomenclature_observation_status,
      id_nomenclature_blurring = NEW.id_nomenclature_blurring,
      id_nomenclature_source_status = NEW.id_nomenclature_source_status,
      determiner = NEW.determiner,
      id_nomenclature_determination_method = NEW.id_nomenclature_determination_method,
      id_nomenclature_behaviour = id_nomenclature_behaviour,
      cd_nom = NEW.cd_nom,
      nom_cite = NEW.nom_cite,
      meta_v_taxref = NEW.meta_v_taxref,
      sample_number_proof = NEW.sample_number_proof,
      digital_proof = NEW.digital_proof,
      non_digital_proof = NEW.non_digital_proof,
      comment_description = NEW.comment,
      last_action = 'U',
	  additional_data = NEW.additional_fields || pr_occtax.t_releves_occtax.additional_fields || pr_occtax.cor_counting_occtax.additional_fields
	FROM pr_occtax.t_releves_occtax 
	JOIN pr_occtax.cor_counting_occtax ON NEW.id_occurrence_occtax = pr_occtax.cor_counting_occtax.id_occurrence_occtax
    WHERE unique_id_sinp = pr_occtax.cor_counting_occtax.unique_id_sinp_occtax;
	
    RETURN NULL;
  END;
  $BODY$;

CREATE OR REPLACE FUNCTION pr_occtax.fct_tri_synthese_update_releve()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    VOLATILE
    COST 100
AS $BODY$  DECLARE
    myobservers text;
  BEGIN
    --calcul de l'observateur. On privilégie le ou les observateur(s) de cor_role_releves_occtax
    --Récupération et formatage des observateurs
    SELECT INTO myobservers array_to_string(array_agg(rol.nom_role || ' ' || rol.prenom_role), ', ')
    FROM pr_occtax.cor_role_releves_occtax cor
    JOIN utilisateurs.t_roles rol ON rol.id_role = cor.id_role
    WHERE cor.id_releve_occtax = NEW.id_releve_occtax;
    IF myobservers IS NULL THEN
      myobservers = NEW.observers_txt;
    END IF;
    --mise à jour en synthese des informations correspondant au relevé uniquement
    UPDATE gn_synthese.synthese SET
        id_dataset = NEW.id_dataset,
        observers = myobservers,
        id_digitiser = NEW.id_digitiser,
        grp_method = NEW.grp_method,
        id_nomenclature_grp_typ = NEW.id_nomenclature_grp_typ,
        date_min = date_trunc('day',NEW.date_min)+COALESCE(NEW.hour_min,'00:00:00'::time),
        date_max = date_trunc('day',NEW.date_max)+COALESCE(NEW.hour_max,'00:00:00'::time),
        altitude_min = NEW.altitude_min,
        altitude_max = NEW.altitude_max,
        depth_min = NEW.depth_min,
        depth_max = NEW.depth_max,
        place_name = NEW.place_name,
        precision = NEW.precision,
        the_geom_4326 = NEW.geom_4326,
        the_geom_point = ST_CENTROID(NEW.geom_4326),
        id_nomenclature_geo_object_nature = NEW.id_nomenclature_geo_object_nature,
        last_action = 'U',
        comment_context = NEW.comment,
		additional_data = NEW.additional_fields || occurrence.additional_fields || counting.additional_fields
	FROM pr_occtax.t_occurrences_occtax occurrence 
	JOIN pr_occtax.cor_counting_occtax counting
		ON counting.id_occurrence_occtax = occurrence.id_occurrence_occtax
		AND NEW.id_releve_occtax = occurrence.id_releve_occtax
	WHERE unique_id_sinp IN (SELECT unnest(pr_occtax.get_unique_id_sinp_from_id_releve(NEW.id_releve_occtax::integer)));
    RETURN NULL;
  END;
  $BODY$;

-- Ajout des tables de gestion des champs additionnels
CREATE TABLE gn_commons.bib_widgets (
	id_widget serial NOT NULL,
	widget_name varchar(50) NOT NULL
);  
  
CREATE TABLE gn_commons.t_additional_fields (
	id_field serial NOT NULL,
	field_name varchar(255) NOT NULL,
	field_label varchar(50) NOT NULL,
	required bool NOT NULL DEFAULT false,
	description text NULL,
	id_widget int4 NOT NULL,
	quantitative bool NULL DEFAULT false,
	unity varchar(50) NULL,
	additional_attributes jsonb NULL,
	code_nomenclature_type varchar(255) NULL,
	field_values jsonb NULL,
  multiselect boolean NULL,
  id_list integer,
  key_label varchar(250),
  key_value varchar(250),
  api varchar(250),
  exportable boolean default TRUE,
  field_order integer NULL 
);

CREATE TABLE gn_commons.cor_field_object(
 id_field integer,
 id_object integer
);

CREATE TABLE gn_commons.cor_field_module(
 id_field integer,
 id_module integer
);

CREATE TABLE gn_commons.cor_field_dataset(
 id_field integer,
 id_dataset integer
);

ALTER TABLE ONLY gn_commons.bib_widgets
    ADD CONSTRAINT pk_bib_widgets PRIMARY KEY (id_widget);

ALTER TABLE ONLY gn_commons.t_additional_fields
    ADD CONSTRAINT pk_t_additional_fields PRIMARY KEY (id_field);

ALTER TABLE ONLY gn_commons.cor_field_module
    ADD CONSTRAINT pk_cor_field_module PRIMARY KEY (id_field, id_module);

ALTER TABLE ONLY gn_commons.cor_field_object
    ADD CONSTRAINT pk_cor_field_object PRIMARY KEY (id_field, id_object);

ALTER TABLE ONLY gn_commons.cor_field_dataset
    ADD CONSTRAINT pk_cor_field_dataset PRIMARY KEY (id_field, id_dataset);

ALTER TABLE ONLY gn_commons.t_additional_fields
  ADD CONSTRAINT fk_t_additional_fields_id_widget FOREIGN KEY (id_widget) 
  REFERENCES gn_commons.bib_widgets(id_widget) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY gn_commons.cor_field_object
  ADD CONSTRAINT fk_cor_field_obj_field FOREIGN KEY (id_field) 
  REFERENCES gn_commons.t_additional_fields(id_field) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY gn_commons.cor_field_object
  ADD CONSTRAINT fk_cor_field_object FOREIGN KEY (id_object) 
  REFERENCES gn_permissions.t_objects(id_object) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY gn_commons.cor_field_module
  ADD CONSTRAINT fk_cor_field_module_field FOREIGN KEY (id_field) 
  REFERENCES gn_commons.t_additional_fields(id_field) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY gn_commons.cor_field_module
  ADD CONSTRAINT fk_cor_field_module FOREIGN KEY (id_module) 
  REFERENCES gn_commons.t_modules(id_module) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY gn_commons.cor_field_dataset
  ADD CONSTRAINT fk_cor_field_dataset_field FOREIGN KEY (id_field) 
  REFERENCES gn_commons.t_additional_fields(id_field) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY gn_commons.cor_field_dataset
  ADD CONSTRAINT fk_cor_field_dataset FOREIGN KEY (id_dataset) 
  REFERENCES gn_meta.t_datasets(id_dataset) ON UPDATE CASCADE ON DELETE CASCADE;

-- Insertion des données de référence pour les champs additionnels
INSERT INTO gn_permissions.t_objects (code_object, description_object) VALUES 
  ('OCCTAX_RELEVE', 'Représente la table pr_occtax.t_releves_occtax'),
  ('OCCTAX_OCCURENCE', 'Représente la table pr_occtax.t_occurrences_occtax'),
  ('OCCTAX_DENOMBREMENT', 'Représente la table pr_occtax.cor_counting_occtax')
  ;

INSERT INTO gn_commons.bib_widgets (widget_name) VALUES ('select'),
	 ('checkbox'),
	 ('nomenclature'),
	 ('text'),
	 ('textarea'),
	 ('radio'),
	 ('time'),
	 ('medias'),
	 ('bool_radio'),
	 ('date'),
	 ('multiselect'),
	 ('number'),
	 ('taxonomy'),
	 ('observers'),
	 ('html');

COMMIT;

----------------------------------
-- MONITORING - DATES & HISTORY --
----------------------------------

-- Ajout trigger sur date_max de la visite

-- Mise à jour des données
UPDATE  gn_monitoring.t_base_visits SET date_max = date_min
WHERE date_max < date_min;

CREATE OR REPLACE FUNCTION gn_monitoring.fct_trg_visite_date_max()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
	-- Si la date max de la visite est nulle ou inférieure à la date_min
	--	Modification de date max pour garder une cohérence des données
	IF
		NEW.visit_date_max IS NULL
		OR NEW.visit_date_max < NEW.visit_date_min
	THEN
      NEW.visit_date_max := NEW.visit_date_min;
    END IF;
  RETURN NEW;
END;
$function$
;

CREATE TRIGGER tri_visite_date_max
  BEFORE INSERT OR UPDATE OF visit_date_min
  ON gn_monitoring.t_base_visits
  FOR EACH ROW
  EXECUTE FUNCTION gn_monitoring.fct_trg_visite_date_max();


--- Historisation de la table cor_visit_observer
ALTER TABLE gn_monitoring.cor_visit_observer ADD unique_id_core_visit_observer uuid  NOT NULL DEFAULT uuid_generate_v4();

INSERT INTO gn_commons.bib_tables_location(table_desc, schema_name, table_name, pk_field, uuid_field_name)
VALUES
('Liste des observateurs d''une visite', 'gn_monitoring', 'cor_visit_observer', 'unique_id_core_visit_observer', 'unique_id_core_visit_observer');

CREATE TRIGGER tri_log_changes_cor_visit_observer
AFTER INSERT OR DELETE OR UPDATE
ON gn_monitoring.cor_visit_observer
FOR EACH ROW EXECUTE FUNCTION gn_commons.fct_trg_log_changes();

