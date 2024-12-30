import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="table-order"
export default class extends Controller {
  static targets = ["orderBy"]
  connect() {}

  orderByTargetConnected(element) {
    element.dataset.action = 'click->table-order#sort'
  }

  sort(event) {
    // get table's frame from element
    const turboType = this.element.dataset.turboType
    // get order parameters from triggering element
    const orderBy = event.target.dataset.orderBy
    const order = event.target.dataset.order == 'ASC' ? 'DESC' : 'ASC'

    // Change or append order parameters in the url
    var params = new URLSearchParams(location.search)
    if (params.has('order_by') && params.has('order')) {
      params.set('order_by', orderBy)
      params.set('order', order)
    } else {
      params.append('order_by', orderBy)
      params.append('order', order)
    }

    // Revisit page with turbo to reload the table's frame
    const newUrl = `${location.origin}${location.pathname}?${params}`;
    Turbo.visit(newUrl, { frame: turboType });
  }
}
