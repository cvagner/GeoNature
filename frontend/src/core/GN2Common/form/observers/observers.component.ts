import { Component, OnInit, Input, Output, EventEmitter, ViewEncapsulation } from '@angular/core';
import { FormControl, FormGroup } from '@angular/forms';
import { DataFormService } from '../data-form.service';
import { Observable } from 'rxjs/Observable';

@Component({
  selector: 'pnx-observers',
  templateUrl: './observers.component.html',
  styleUrls: ['./observers.component.scss'],
  encapsulation: ViewEncapsulation.None
})
export class ObserversComponent implements OnInit {

  filteredObservers: Array<any>;
  @Input()idMenu: number;
  @Input() placeholder: string;
  @Input() parentFormControl:FormControl;
  @Output() observerSelected = new EventEmitter<any>();
  @Output() observerDeleted = new EventEmitter<any>();

  observers: Array<any>;
  selectedObservers: Array<string>;

  constructor(private _dfService: DataFormService) {
   }

  ngOnInit() {
    this.selectedObservers = [];
    this._dfService.getObservers(this.idMenu)
      .subscribe(data => this.observers = data);
  }

  filterObservers(event) {
    const query = event.query;
    this.filteredObservers = this.observers.filter(obs => {
      return obs.nom_complet.toLowerCase().indexOf(query.toLowerCase()) === 0
    })
  }
  addObservers(observer) {
    this.observerSelected.emit(observer);
  }
  removeObservers(observer) {
    this.observerDeleted.emit(observer);
  }

    


}
