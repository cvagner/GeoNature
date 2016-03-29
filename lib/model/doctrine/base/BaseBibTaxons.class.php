<?php

/**
 * BaseBibTaxons
 * 
 * This class has been auto-generated by the Doctrine ORM Framework
 * 
 * @property integer $id_taxon
 * @property integer $cd_nom
 * @property string $nom_latin
 * @property string $nom_francais
 * @property string $auteur
 * @property string $filtre1
 * @property string $filtre2
 * @property string $filtre3
 * @property string $filtre4
 * @property string $filtre5
 * @property string $filtre6
 * @property string $filtre7
 * @property string $filtre8
 * @property string $filtre9
 * @property string $filtre10
 * @property Taxref $Taxref
 * @property Doctrine_Collection $CorMessageTaxonCf
 * @property Doctrine_Collection $CorMessageTaxonCflore
 * @property Doctrine_Collection $CorMessageTaxonInv
 * @property Doctrine_Collection $CorTaxonAttribut
 * @property Doctrine_Collection $CorTaxonListe
 * @property Doctrine_Collection $CorUniteTaxon
 * @property Doctrine_Collection $CorUniteTaxonCflore
 * @property Doctrine_Collection $CorUniteTaxonInv
 * @property Doctrine_Collection $TRelevesCf
 * @property Doctrine_Collection $TRelevesCflore
 * @property Doctrine_Collection $TRelevesInv
 * @property Doctrine_Collection $VNomadeTaxonsFaune
 * @property Doctrine_Collection $VNomadeTaxonsFlore
 * @property Doctrine_Collection $VNomadeTaxonsInv
 * @property Doctrine_Collection $VTreeTaxonsSynthese
 * 
 * @method integer             getIdTaxon()               Returns the current record's "id_taxon" value
 * @method integer             getCdNom()                 Returns the current record's "cd_nom" value
 * @method string              getNomLatin()              Returns the current record's "nom_latin" value
 * @method string              getNomFrancais()           Returns the current record's "nom_francais" value
 * @method string              getAuteur()                Returns the current record's "auteur" value
 * @method string              getFiltre1()               Returns the current record's "filtre1" value
 * @method string              getFiltre2()               Returns the current record's "filtre2" value
 * @method string              getFiltre3()               Returns the current record's "filtre3" value
 * @method string              getFiltre4()               Returns the current record's "filtre4" value
 * @method string              getFiltre5()               Returns the current record's "filtre5" value
 * @method string              getFiltre6()               Returns the current record's "filtre6" value
 * @method string              getFiltre7()               Returns the current record's "filtre7" value
 * @method string              getFiltre8()               Returns the current record's "filtre8" value
 * @method string              getFiltre9()               Returns the current record's "filtre9" value
 * @method string              getFiltre10()              Returns the current record's "filtre10" value
 * @method Taxref              getTaxref()                Returns the current record's "Taxref" value
 * @method Doctrine_Collection getCorMessageTaxonCf()     Returns the current record's "CorMessageTaxonCf" collection
 * @method Doctrine_Collection getCorMessageTaxonCflore() Returns the current record's "CorMessageTaxonCflore" collection
 * @method Doctrine_Collection getCorMessageTaxonInv()    Returns the current record's "CorMessageTaxonInv" collection
 * @method Doctrine_Collection getCorTaxonAttribut()      Returns the current record's "CorTaxonAttribut" collection
 * @method Doctrine_Collection getCorTaxonListe()         Returns the current record's "CorTaxonListe" collection
 * @method Doctrine_Collection getCorUniteTaxon()         Returns the current record's "CorUniteTaxon" collection
 * @method Doctrine_Collection getCorUniteTaxonCflore()   Returns the current record's "CorUniteTaxonCflore" collection
 * @method Doctrine_Collection getCorUniteTaxonInv()      Returns the current record's "CorUniteTaxonInv" collection
 * @method Doctrine_Collection getTRelevesCf()            Returns the current record's "TRelevesCf" collection
 * @method Doctrine_Collection getTRelevesCflore()        Returns the current record's "TRelevesCflore" collection
 * @method Doctrine_Collection getTRelevesInv()           Returns the current record's "TRelevesInv" collection
 * @method Doctrine_Collection getVNomadeTaxonsFaune()    Returns the current record's "VNomadeTaxonsFaune" collection
 * @method Doctrine_Collection getVNomadeTaxonsFlore()    Returns the current record's "VNomadeTaxonsFlore" collection
 * @method Doctrine_Collection getVNomadeTaxonsInv()      Returns the current record's "VNomadeTaxonsInv" collection
 * @method Doctrine_Collection getVTreeTaxonsSynthese()   Returns the current record's "VTreeTaxonsSynthese" collection
 * @method BibTaxons           setIdTaxon()               Sets the current record's "id_taxon" value
 * @method BibTaxons           setCdNom()                 Sets the current record's "cd_nom" value
 * @method BibTaxons           setNomLatin()              Sets the current record's "nom_latin" value
 * @method BibTaxons           setNomFrancais()           Sets the current record's "nom_francais" value
 * @method BibTaxons           setAuteur()                Sets the current record's "auteur" value
 * @method BibTaxons           setFiltre1()               Sets the current record's "filtre1" value
 * @method BibTaxons           setFiltre2()               Sets the current record's "filtre2" value
 * @method BibTaxons           setFiltre3()               Sets the current record's "filtre3" value
 * @method BibTaxons           setFiltre4()               Sets the current record's "filtre4" value
 * @method BibTaxons           setFiltre5()               Sets the current record's "filtre5" value
 * @method BibTaxons           setFiltre6()               Sets the current record's "filtre6" value
 * @method BibTaxons           setFiltre7()               Sets the current record's "filtre7" value
 * @method BibTaxons           setFiltre8()               Sets the current record's "filtre8" value
 * @method BibTaxons           setFiltre9()               Sets the current record's "filtre9" value
 * @method BibTaxons           setFiltre10()              Sets the current record's "filtre10" value
 * @method BibTaxons           setTaxref()                Sets the current record's "Taxref" value
 * @method BibTaxons           setCorMessageTaxonCf()     Sets the current record's "CorMessageTaxonCf" collection
 * @method BibTaxons           setCorMessageTaxonCflore() Sets the current record's "CorMessageTaxonCflore" collection
 * @method BibTaxons           setCorMessageTaxonInv()    Sets the current record's "CorMessageTaxonInv" collection
 * @method BibTaxons           setCorTaxonAttribut()      Sets the current record's "CorTaxonAttribut" collection
 * @method BibTaxons           setCorTaxonListe()         Sets the current record's "CorTaxonListe" collection
 * @method BibTaxons           setCorUniteTaxon()         Sets the current record's "CorUniteTaxon" collection
 * @method BibTaxons           setCorUniteTaxonCflore()   Sets the current record's "CorUniteTaxonCflore" collection
 * @method BibTaxons           setCorUniteTaxonInv()      Sets the current record's "CorUniteTaxonInv" collection
 * @method BibTaxons           setTRelevesCf()            Sets the current record's "TRelevesCf" collection
 * @method BibTaxons           setTRelevesCflore()        Sets the current record's "TRelevesCflore" collection
 * @method BibTaxons           setTRelevesInv()           Sets the current record's "TRelevesInv" collection
 * @method BibTaxons           setVNomadeTaxonsFaune()    Sets the current record's "VNomadeTaxonsFaune" collection
 * @method BibTaxons           setVNomadeTaxonsFlore()    Sets the current record's "VNomadeTaxonsFlore" collection
 * @method BibTaxons           setVNomadeTaxonsInv()      Sets the current record's "VNomadeTaxonsInv" collection
 * @method BibTaxons           setVTreeTaxonsSynthese()   Sets the current record's "VTreeTaxonsSynthese" collection
 * 
 * @package    geonature
 * @subpackage model
 * @author     Gil Deluermoz
 * @version    SVN: $Id: Builder.php 7490 2010-03-29 19:53:27Z jwage $
 */
abstract class BaseBibTaxons extends sfDoctrineRecord
{
    public function setTableDefinition()
    {
        $this->setTableName('taxonomie.bib_taxons');
        $this->hasColumn('id_taxon', 'integer', 4, array(
             'type' => 'integer',
             'primary' => true,
             'length' => 4,
             ));
        $this->hasColumn('cd_nom', 'integer', 4, array(
             'type' => 'integer',
             'length' => 4,
             ));
        $this->hasColumn('nom_latin', 'string', 100, array(
             'type' => 'string',
             'length' => 100,
             ));
        $this->hasColumn('nom_francais', 'string', 50, array(
             'type' => 'string',
             'length' => 50,
             ));
        $this->hasColumn('auteur', 'string', 50, array(
             'type' => 'string',
             'length' => 50,
             ));
        $this->hasColumn('filtre1', 'string', 255, array(
             'type' => 'string',
             'length' => 255,
             ));
        $this->hasColumn('filtre2', 'string', 255, array(
             'type' => 'string',
             'length' => 255,
             ));
        $this->hasColumn('filtre3', 'string', 255, array(
             'type' => 'string',
             'length' => 255,
             ));
        $this->hasColumn('filtre4', 'string', 255, array(
             'type' => 'string',
             'length' => 255,
             ));
        $this->hasColumn('filtre5', 'string', 255, array(
             'type' => 'string',
             'length' => 255,
             ));
        $this->hasColumn('filtre6', 'string', 255, array(
             'type' => 'string',
             'length' => 255,
             ));
        $this->hasColumn('filtre7', 'string', 255, array(
             'type' => 'string',
             'length' => 255,
             ));
        $this->hasColumn('filtre8', 'string', 255, array(
             'type' => 'string',
             'length' => 255,
             ));
        $this->hasColumn('filtre9', 'string', 255, array(
             'type' => 'string',
             'length' => 255,
             ));
        $this->hasColumn('filtre10', 'string', 255, array(
             'type' => 'string',
             'length' => 255,
             ));
    }

    public function setUp()
    {
        parent::setUp();
        $this->hasOne('Taxref', array(
             'local' => 'cd_nom',
             'foreign' => 'cd_nom'));

        $this->hasMany('CorMessageTaxonCf', array(
             'local' => 'id_taxon',
             'foreign' => 'id_taxon'));

        $this->hasMany('CorMessageTaxonCflore', array(
             'local' => 'id_taxon',
             'foreign' => 'id_taxon'));

        $this->hasMany('CorMessageTaxonInv', array(
             'local' => 'id_taxon',
             'foreign' => 'id_taxon'));

        $this->hasMany('CorTaxonAttribut', array(
             'local' => 'id_taxon',
             'foreign' => 'id_taxon'));

        $this->hasMany('CorTaxonListe', array(
             'local' => 'id_taxon',
             'foreign' => 'id_taxon'));

        $this->hasMany('CorUniteTaxon', array(
             'local' => 'id_taxon',
             'foreign' => 'id_taxon'));

        $this->hasMany('CorUniteTaxonCflore', array(
             'local' => 'id_taxon',
             'foreign' => 'id_taxon'));

        $this->hasMany('CorUniteTaxonInv', array(
             'local' => 'id_taxon',
             'foreign' => 'id_taxon'));

        $this->hasMany('TRelevesCf', array(
             'local' => 'id_taxon',
             'foreign' => 'id_taxon'));

        $this->hasMany('TRelevesCflore', array(
             'local' => 'id_taxon',
             'foreign' => 'id_taxon'));

        $this->hasMany('TRelevesInv', array(
             'local' => 'id_taxon',
             'foreign' => 'id_taxon'));

        $this->hasMany('VNomadeTaxonsFaune', array(
             'local' => 'id_taxon',
             'foreign' => 'id_taxon'));

        $this->hasMany('VNomadeTaxonsFlore', array(
             'local' => 'id_taxon',
             'foreign' => 'id_taxon'));

        $this->hasMany('VNomadeTaxonsInv', array(
             'local' => 'id_taxon',
             'foreign' => 'id_taxon'));

        $this->hasMany('VTreeTaxonsSynthese', array(
             'local' => 'id_taxon',
             'foreign' => 'id_taxon'));
    }
}