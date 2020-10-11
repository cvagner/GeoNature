import {
  Component,
  OnInit,
  Input,
  EventEmitter,
  Output,
  OnChanges,
  ElementRef,
  ViewChild,
  HostListener
} from '@angular/core';
import { FormControl } from '@angular/forms';
import { TranslateService } from '@ngx-translate/core';

/**
 * Ce composant permet d'afficher un input de type multiselect à partir
 * d'une liste de valeurs passé en Input.
 *
 * @example
 * <pnx-multiselect
 *   label="Organisme"
 *   [values]="organisms"
 *   [parentFormControl]="form.controls.organisms"
 *   keyLabel="nom_organisme"
 *   keyValue="id_organisme"
 *   (onChange)="doWhatever($event)"
 *   (onDelete)="deleteCallback($event)"
 *   (onSearch)="filterItems($event)"
 * >
 * </pnx-multiselect>
 */
@Component({
  selector: 'pnx-multiselect',
  templateUrl: './multiselect.component.html',
  styleUrls: ['./multiselect.component.scss']
})
export class MultiSelectComponent implements OnInit, OnChanges {
  public selectedItems = [];
  public searchControl = new FormControl();
  public formControlValue = [];
  public savedValues = [];

  @Input() parentFormControl: FormControl;
  /** Valeurs à afficher dans la liste déroulante. Doit être un tableau
   * de dictionnaire.
   */
  @Input() values: Array<any>;
  /** Clé du dictionnaire de valeur que le composant doit prendre pour
   * l'affichage de la liste déroulante.
   */
  @Input() keyLabel: string;
  /** Clé du dictionnaire que le composant doit passer au formControl */
  @Input() keyValue: string;
  /** Est-ce que le composant doit afficher l'item "tous" dans les
   * options du select ?
   */
  @Input() displayAll: boolean;
  /** Affiche la barre de recherche (=true). */
  @Input() searchBar: boolean;
 /** Désactive le contrôle de formulaire. */
  @Input() disabled: boolean;
  /** Initutlé du contrôle de formulaire. */
  @Input() label: any;
  /**
   * Booléan qui permet de passer tout l'objet au formControl, et pas
   * seulement une propriété de l'objet renvoyé par l'API.
   *
   * Facultatif, par défaut à ``false``, c'est alors l'attribut passé en
   * Input ``keyValue`` qui est renvoyé au formControl.
   * Lorsque l'on passe ``true`` à cet Input, l'Input ``keyValue``
   * devient inutile.
   * L'API qui renvoit séléctionnées au formulaire doit être un tableau
   * d'entier et non un tableau d'items
   */
  @Input() bindAllItem: false;
  /** Temps en millisecondes avant lancement d'une recherche avec les
   * caractères saisis dans la zone de recherche.
   *
   * Par défaut, 100 millisecondes.
   */
  @Input() debounceTime: number;
  /** Action à exécuter lors d'une recherche. */
  @Output() onSearch = new EventEmitter();
  /** Action à exécuter lors du changement du contenu. */
  @Output() onChange = new EventEmitter<any>();
  /** Action à exécuter lors de la suppression du contenu. */
  @Output() onDelete = new EventEmitter<any>();

  @ViewChild('button_input') el: ElementRef;

  /** Pour la selection au clavier. */
  public valSave;

  /** @ignore */
  constructor(private _translate: TranslateService) {}

  // you can pass whatever callback to the onSearch output, to trigger
  // database research or simple search on an array
  ngOnInit() {
    this.debounceTime = this.debounceTime || 100;
    this.disabled = this.disabled || false;
    this.searchBar = this.searchBar || false;
    this.displayAll = this.displayAll || false;

    // Set the value
    if (this.values && this.parentFormControl.value) {
      if (this.bindAllItem) {
        this.values.forEach(value => {
          if (this.parentFormControl.value.indexOf(value) !== -1) {
            this.selectedItems.push(value);
          }
        });
      } else {
        this.values.forEach(value => {
          if (this.parentFormControl.value.indexOf(value[this.keyValue]) !== -1) {
            this.selectedItems.push(value);
          }
        });
      }
    }

    // Subscribe and output on the search bar
    this.searchControl.valueChanges
      .debounceTime(this.debounceTime)
      .distinctUntilChanged()
      .subscribe(value => {
        this.onSearch.emit(value);
      });

    // When data his push via 'patchValue' (API POST data for example)
    this.parentFormControl.valueChanges.subscribe(value => {
      if (this.values && this.values.length < 1) {
        return;
      }
      // If the new value is null
      // refresh selectedItems, formcontrolValue and values to display
      if (value === null) {
        this.selectedItems = [];
        this.formControlValue = [];
        this.values = this.savedValues;
      } else {
        // When patch value when init the component
        // push the item only if selected items == 0 (to not push twice
        // the object when the formControl is patch)
        if (this.selectedItems.length === 0) {
          value.forEach(item => {
            if (this.bindAllItem) {
              this.addItem(item, false);
            } else {
              // If not bind all item (the formControl send an integer)
              // we must find in the values array the current item
              for (let i = 0; i < (this.values || []).length; i++) {
                if (this.values[i][this.keyValue] === item) {
                  this.addItem(this.values[i], false);
                  break;
                }
              }
            }
          });
        }
      }
    });
  }

  /**
   * Ajoute l'élément courant au formControl (l'oject complet si
   * bindAllItems=True, sinon seulement l'id (keyValue)).
   * Filtre la liste pour ne pas afficher de doublon.
   * @param item : l'objet complet (pas l'id).
   */
  addItem(item, markDirty = true) {
    // Mark dirty only if its an user action
    if (markDirty) {
      this.parentFormControl.markAsDirty();
    }

    // Remove element from the items list to avoid doublon
    if (this.values) {
      this.values = this.values.filter(curItem => {
        return curItem[this.keyLabel] !== item[this.keyLabel];
      });
    }

    if (item === 'all') {
      this.selectedItems = [];
      this._translate.get('AllItems', { value: 'AllItems' }).subscribe(value => {
        const objAll = {};
        objAll[this.keyLabel] = value;
        this.selectedItems.push(objAll);
      });
      this.formControlValue = [];
      this.parentFormControl.patchValue([]);
      return;
    }
    // Set the item for the formControl
    // if bindAllItem -> push the whole object
    // else push only the key of the object( @Input keyValue)
    let updateItem;
    if (this.bindAllItem) {
      updateItem = item;
    } else {
      updateItem = item[this.keyValue];
    }
    this.selectedItems.push(item);
    this.formControlValue.push(updateItem);
    // Set the item for the formControl
    this.parentFormControl.patchValue(this.formControlValue);

    this.searchControl.reset();
    this.onChange.emit(updateItem);
  }

  removeItem($event, item) {
    this.parentFormControl.markAsDirty();
    // Remove element from the items list to avoid doublon
    this.values = this.values.filter(curItem => {
      return curItem[this.keyLabel] !== item[this.keyLabel];
    });
    // Disable event propagation
    $event.stopPropagation();
    // Push the element in the items list
    this.values.push(item);
    this.selectedItems = this.selectedItems.filter(curItem => {
      return curItem[this.keyLabel] !== item[this.keyLabel];
    });
    if (this.bindAllItem) {
      this.formControlValue = this.parentFormControl.value.filter(el => {
        return el !== item;
      });
    } else {
      this.formControlValue = this.parentFormControl.value.filter(el => {
        return el !== item[this.keyValue];
      });
    }
    this.parentFormControl.patchValue(this.formControlValue);

    this.onDelete.emit(item);
  }

  removeDoublon() {
    if (this.values && this.formControlValue) {
      this.values = this.values.filter(v => {
        let isInArray = false;

        this.formControlValue.forEach(element => {
          if (this.bindAllItem) {
            if (v[this.keyValue] === element[this.keyValue]) {
              isInArray = true;
            }
          } else {
            if (v[this.keyValue] === element) {
              isInArray = true;
            }
          }
        });
        return !isInArray;
      });
    }
  }

  onFocus(event) {
    this.valSave = ' ';
  }

  onBlur(event) {
    this.valSave = null;
  }

  setValSave(val = null) {
    this.valSave = val;
  }

  /** Gestion des touches pour la selection au clavier.
   *
   *  Les touche bas et haut pour permettre de se déplacer dans la liste.
   */
  @HostListener('window:keyup', ['$event'])
  keyEvent(event: KeyboardEvent) {
    // Enter (parmet d'ouvrir le composant pour choisir un item)
    if (event.keyCode === 13) {
      if (this.valSave) {
        const valSave = JSON.parse(JSON.stringify(this.valSave));
        this.el.nativeElement.click();
        this.el.nativeElement.focus();
        if (valSave !== ' ') {
          this.addItem(valSave);
        }
      }
    }
    // Down
    if (event.keyCode === 40) {
      if (this.valSave) {
        const element = (event.srcElement as HTMLTextAreaElement).nextElementSibling;
        if (element) {
          (element as HTMLElement).focus();
        }
      }
    }
    // Up
    if (event.keyCode === 38) {
      if (this.valSave) {
        const element = (event.srcElement as HTMLTextAreaElement).previousElementSibling;
        if (element) {
          (element as HTMLElement).focus();
        }
      }
    }
  }

  ngOnChanges(changes) {
    if (changes.values && changes.values.currentValue) {
      this.savedValues = changes.values.currentValue;

      if (this.parentFormControl.value) {
        this.parentFormControl.setValue(this.parentFormControl.value);
      }
      // Remove doublon in the dropdown lists
      // @FIXME: timeout to wait for the formcontrol to be updated
      // the data from formControl can came in AJAX, so we wait for it...
      setTimeout(() => {
        this.removeDoublon();
      }, 2000);
    }
  }
}
