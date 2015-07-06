<?php


class BibTaxonsTable extends Doctrine_Table
{
    
    public static function getInstance()
    {
        return Doctrine_Core::getTable('BibTaxons');
    }
    public static function listAll()
    {
        $query= Doctrine_Query::create()
            ->select('t.id_taxon, t.nom_latin' )
            ->from('BibTaxons t')
            ->orderBy('t.nom_latin')
            ->fetchArray();
        return $query;
    }
    public static function listSynthese()
    {
        $dbh = Doctrine_Manager::getInstance()->getCurrentConnection()->getDbh();
        //requ�te optimis�e = moins 2 secondes
        $sql = "SELECT * FROM synthese.v_taxons_synthese";
        $taxons = $dbh->query($sql)->fetchAll(PDO::FETCH_ASSOC);
        foreach ($taxons as $key => &$val)
        {
            $reglements = explode('#',$val['protections']);
            $reglementations = array();
            foreach ($reglements as $r)
            {
                $p = explode('__',$r);
                $couple['texte']=$p[0];
                $couple['url']= (isset($p[1])) ? $p[1] : '';;
                array_push($reglementations,$couple);
            }
            $val['protections'] = $reglementations;
            if($val['protection_stricte']=='t'){$val['no_protection']=true;}else{$val['no_protection']=false;}
            if($val['nom_francais']==null || $val['nom_francais']=='null' || $val['nom_francais']==''){$val['nom_francais']=$val['nom_latin'];}
        }
        return json_encode($taxons);
    }
    
    public static function listTreeSynthese()
    {
        $query= Doctrine_Query::create()
            ->select('*' )
            ->from('VTreeTaxonsSynthese')
            ->orderBy('nom_latin')
            ->fetchArray();
        foreach ($query as $key => &$val)
        {
            if($val['nom_francais']==null || $val['nom_francais']=='null' || $val['nom_francais']==''){$val['nom_francais']=$val['nom_latin'];}
        }
        return $query;
    }
    
    public static function listCf()
    {
        $query= Doctrine_Query::create()
            ->select('t.id_taxon, t.cd_ref, t.cd_nom, t.nom_latin, t.nom_francais, \'inconnue\' derniere_date, 0 nb_obs, t.id_classe, t.denombrement, t.patrimonial, t.message,\'orange\' couleur' )
            ->distinct()
            ->from('VNomadeTaxonsFaune t')
            ->where('contactfaune = true')
            ->orderBy('t.nom_latin')
            ->fetchArray();
        foreach ($query as $key => &$val)
        {
            if($val['nom_francais']==null || $val['nom_francais']=='null' || $val['nom_francais']==''){$val['nom_francais']=$val['nom_latin'];}
        }
        return $query;
    }
    
    public static function listInv()
    {
        $query= Doctrine_Query::create()
            ->select('t.id_taxon, t.cd_ref, t.cd_nom, t.nom_latin, t.nom_francais, \'inconnue\' derniere_date, 0 nb_obs, t.id_classe, t.patrimonial, t.message,\'orange\' couleur' )
            ->distinct()
            ->from('VNomadeTaxonsInv t')
            ->orderBy('t.nom_latin')
            ->fetchArray(); 
        foreach ($query as $key => &$val)
        {
            if($val['nom_francais']==null || $val['nom_francais']=='null' || $val['nom_francais']==''){$val['nom_francais']=$val['nom_latin'];}
        }
        return $query;
    }

    public static function listCfUnite($id_unite_geo = null)
    {
        $dbh = Doctrine_Manager::getInstance()->getCurrentConnection()->getDbh();
        $sql = "(
                    SELECT DISTINCT t.id_taxon, t.cd_ref, t.nom_latin, t.nom_francais, to_char(cut.derniere_date,'dd/mm/yyyy') AS derniere_date,CAST(cut.nb_obs AS varchar), 
                    t.id_classe, t.denombrement, t.patrimonial, t.message,cut.couleur
                    FROM contactfaune.v_nomade_taxons_faune t
                    LEFT JOIN contactfaune.cor_unite_taxon cut ON cut.id_taxon = t.id_taxon
                    WHERE cut.id_unite_geo = $id_unite_geo
                    AND t.contactfaune = true
                    ORDER BY t.nom_latin
                )
                UNION
                (
                    SELECT DISTINCT t.id_taxon, t.cd_ref, t.nom_latin, t.nom_francais, '' AS derniere_date,null as nb_obs, 
                    t.id_classe, t.denombrement, t.patrimonial, t.message,'orange' AS couleur
                    FROM contactfaune.v_nomade_taxons_faune t
                    WHERE t.id_taxon NOT IN (SELECT id_taxon FROM contactfaune.cor_unite_taxon WHERE id_unite_geo = $id_unite_geo)
                    AND t.contactfaune = true
                    ORDER BY t.nom_latin
                )";
        $taxons = $dbh->query($sql)->fetchAll(PDO::FETCH_ASSOC);
        foreach ($taxons as $key => &$val)
        {
            if($val['nom_francais']==null || $val['nom_francais']=='null' || $val['nom_francais']==''){$val['nom_francais']=$val['nom_latin'];}
        }
        return $taxons;
    }
    public static function listInvUnite($id_unite_geo = null)
    {
        $dbh = Doctrine_Manager::getInstance()->getCurrentConnection()->getDbh();
        $sql = "(
                    SELECT DISTINCT t.id_taxon, t.cd_ref, t.nom_latin, t.nom_francais, to_char(cut.derniere_date,'dd/mm/yyyy') AS derniere_date,CAST(cut.nb_obs AS varchar), 
                    t.id_classe, t.patrimonial, t.message,cut.couleur
                    FROM contactinv.v_nomade_taxons_inv t
                    LEFT JOIN contactinv.cor_unite_taxon_inv cut ON cut.id_taxon = t.id_taxon
                    WHERE cut.id_unite_geo = $id_unite_geo
                    ORDER BY t.nom_latin
                )
                UNION
                (
                    SELECT DISTINCT t.id_taxon, t.cd_ref, t.nom_latin, t.nom_francais, '' AS derniere_date,null as nb_obs, 
                    t.id_classe, t.patrimonial, t.message,'orange' AS couleur
                    FROM contactinv.v_nomade_taxons_inv t
                    WHERE t.id_taxon NOT IN (SELECT id_taxon FROM contactinv.cor_unite_taxon_inv WHERE id_unite_geo = $id_unite_geo)
                    ORDER BY t.nom_latin
                )";
        $taxons = $dbh->query($sql)->fetchAll(PDO::FETCH_ASSOC);
        foreach ($taxons as $key => &$val)
        {
            if($val['nom_francais']==null || $val['nom_francais']=='null' || $val['nom_francais']==''){$val['nom_francais']=$val['nom_latin'];}
        }
        return $taxons;
    }  
}
