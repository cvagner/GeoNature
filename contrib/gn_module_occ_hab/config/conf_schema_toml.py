'''
   Spécification du schéma toml des paramètres de configurations
   La classe doit impérativement s'appeller GnModuleSchemaConf
   Fichier spécifiant les types des paramètres et leurs valeurs par défaut
   Fichier à ne pas modifier. Paramètres surcouchables dans config/config_gn_module.tml
'''

from marshmallow import Schema, fields

class FormConfig(Schema):
   date_min = fields.Boolean(missing=True)
   date_max = fields.Boolean(missing=True)
   depth_min = fields.Boolean(missing=True)
   depth_max = fields.Boolean(missing=True)
   altitude_min = fields.Boolean(missing=True)
   altitude_max = fields.Boolean(missing=True)
   habitat_complex = fields.Boolean(missing=True)
   exposure = fields.Boolean(missing=True)
   area = fields.Boolean(missing=True)
   area_surface_calculation = fields.Boolean(missing=True)
   comment = fields.Boolean(missing=True)
   geographic_object = fields.Boolean(missing=True)
   determination_type = fields.Boolean(missing=True)
   determiner = fields.Boolean(missing=True)
   collection_technique = fields.Boolean(missing=True)
   recovery_percentage = fields.Boolean(missing=True)
   id_nomenclature_abundance = fields.Boolean(missing=True)
   technical_precision = fields.Boolean(missing=True)
   technical_precision = fields.Boolean(missing=True)
   

class GnModuleSchemaConf(Schema):
    ID_LIST_HABITAT = fields.Integer(missing=1)
    OBSERVER_AS_TXT = fields.Integer(missing=False)
    formConfig = fields.Nested(FormConfig, missing=dict())
