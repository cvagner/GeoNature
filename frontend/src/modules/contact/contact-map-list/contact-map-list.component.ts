import { Component, OnInit, OnDestroy } from '@angular/core';
import { Http } from '@angular/http';
import { AppConfig } from '../../../conf/app.config';
import { GeoJSON } from 'leaflet';
import { MapListService } from '../../../core/GN2Common/map-list/map-list.service';
import { Subscription } from 'rxjs/Subscription';
import { ContactService } from '../services/contact.service';
import { CommonService } from '../../../core/GN2Common/service/common.service';
import { AuthService } from '../../../core/components/auth/auth.service';
import { CookieService } from 'ng2-cookies';
import {TranslateService} from '@ngx-translate/core';
import { Router } from '@angular/router';
import { FormControl } from '@angular/forms';

@Component({
  selector: 'pnx-contact-map-list',
  templateUrl: 'contact-map-list.component.html',
  styleUrls: ['./contact-map-list.component.scss']
})

export class ContactMapListComponent implements OnInit {
  public geojsonData: GeoJSON;
  public displayColumns: Array<any>;
  public pathEdit: string;
  public pathInfo: string;
  public idName: string;
  public apiEndPoint: string;
  public inputTaxon = new FormControl();
  public inputObservers = new FormControl();
  public dateMin = new FormControl();
  public dateMax = new FormControl();
  constructor( private _http: Http, private _mapListService: MapListService, private _contactService: ContactService,
    private _commonService: CommonService, private _auth: AuthService
   , private _translate: TranslateService) { }

  ngOnInit() {

  this.displayColumns = [
   {prop: 'taxons', name: 'Taxon', display: true},
   {prop: 'observateurs', 'name': 'Observateurs'},
  ];
  this.pathEdit = 'occtax/form';
  this.pathInfo = 'occtax/info';
  this.idName = 'id_releve_contact';
  this.apiEndPoint = 'contact/vreleve';

  this._mapListService.getData('contact/vreleve')
    .subscribe(res => {
      this._mapListService.page.totalElements = res.items.features.length;
      this.geojsonData = res.items;
    });
  }

   deleteReleve(id) {
    this._contactService.deleteReleve(id)
      .subscribe(
        data => {
          this._mapListService.deleteObs(id);
            this._commonService.translateToaster('success', 'Releve.DeleteSuccessfully');

        },
        error => {
          if (error.status === 403) {
            this._commonService.translateToaster('error', 'NotAllowed');
          } else {
            this._commonService.translateToaster('error', 'ErrorMessage');
          }

        });
   }

   taxonChanged(taxonObj) {
    // refresh taxon in url query
    this._mapListService.urlQuery = this._mapListService.urlQuery.delete('cd_nom');
    this._mapListService.refreshData(this.apiEndPoint, {param: 'cd_nom', 'value': taxonObj.cd_nom});
  }

  observerChanged(observer) {
    this._mapListService.refreshData(this.apiEndPoint, {param: 'observer', 'value': observer.id_role});
  }

  observerDeleted(observer) {
    const idObservers = this._mapListService.urlQuery.getAll('observer');
    this._mapListService.urlQuery = this._mapListService.urlQuery.delete('observer');
    idObservers.forEach(id => {
      if (id !== observer.id_role) {
        this._mapListService.urlQuery = this._mapListService.urlQuery.set('observer', id);
      }
    });
    this._mapListService.refreshData(this.apiEndPoint);
  }

  dateMinChanged(date) {
    this._mapListService.urlQuery = this._mapListService.urlQuery.delete('date_up');
    if (date.length > 0) {
      this._mapListService.refreshData(this.apiEndPoint, {param: 'date_up', 'value': date});
    } else {
      this._mapListService.deleteAndRefresh(this.apiEndPoint, 'date_up');
    }
  }
  dateMaxChanged(date) {
    this._mapListService.urlQuery = this._mapListService.urlQuery.delete('date_low');
    if (date.length > 0) {
      this._mapListService.refreshData(this.apiEndPoint, {param: 'date_low', 'value': date});
    }else {
      this._mapListService.deleteAndRefresh(this.apiEndPoint, 'date_low');
    }
  }

}


