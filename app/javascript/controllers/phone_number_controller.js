import { Controller } from "@hotwired/stimulus";
import "inputmask";

// Connects to data-controller="phone-number"
export default class extends Controller {
  connect() {
    Inputmask({"mask": "(999) 999-9999"}).mask(this.element)
  }
}
