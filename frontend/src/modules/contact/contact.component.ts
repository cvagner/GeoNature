import { Component, OnInit } from '@angular/core';
import { NavService } from '../../core/services/nav.service';
import { MapService } from '../../core/GN2Common/map/map.service';


@Component({
  selector: 'pnx-contact',
  templateUrl: './contact.component.html',
  styleUrls: ['./contact.component.scss'],
  providers: [MapService]
})
export class ContactComponent implements OnInit {

  constructor(private _navService: NavService) {
      _navService.setAppName('Contact Faune');
  }

  ngOnInit() {
  }

}
