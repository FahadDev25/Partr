import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="text-complete"
export default class extends Controller {
  connect() {
    this.element.dataset.action = 'input->text-complete#input'
    this.input()
  }

  input() {
    // get value of the textbox
    const value = this.element.value
    // get data-url from the textbox
    const url = this.element.dataset.url
    // fetch turbo-type from the textbox
    const turboType = this.element.dataset.turboType
    // create new url with the value
    this.url = (`${url}?prefix=${value}`)

    // replace the turbo-frame with the new url
    let frame = document.querySelector(`turbo-frame#${turboType}`)
    frame.src = this.url
    frame.reload()
  }
}
