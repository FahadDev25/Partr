import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"

// Connects to data-controller="tom-select"
export default class extends Controller {
  connect() {
    var options = {
      plugins: this.element.dataset.plugins.split(","),
      allowEmptyOption: true,
      placeholder: this.element.dataset.placeholder,
      copyClassesToDropdown: true,
      create: this.element.dataset.create,
      maxOptions: null
    }
    this.select = new TomSelect(this.element, options);
  }
}
