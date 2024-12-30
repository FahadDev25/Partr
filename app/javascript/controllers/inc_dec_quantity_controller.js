import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="inc-dec-quantity"
export default class extends Controller {
  static targets = ["increment", "decrement", "quantity"]
  connect() {
    this.incrementTarget.dataset.action = 'click->inc-dec-quantity#inc_quantity'
    this.decrementTarget.dataset.action = 'click->inc-dec-quantity#dec_quantity'
  }

  inc_quantity(event) {
    this.quantityTarget.value = parseFloat(this.quantityTarget.value || 0) + parseFloat(event.target.dataset.amount)
  }

  dec_quantity(event) {
    this.quantityTarget.value -= event.target.dataset.amount
  }
}
