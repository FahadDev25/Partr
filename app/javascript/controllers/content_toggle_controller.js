import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="content-toggle"
export default class extends Controller {
  connect() {
    this.element.dataset.action = "input->content-toggle#toggle"
    this.toggle()
  }

  toggle() {
    this.get_content()
    this.changeFrame()
  }

  get_content() {
    // get data-url1 and data-url2 from the toggle
    const url1 = this.element.dataset.url1
    const url2 = this.element.dataset.url2

    // get value from toggle
    var checked = this.element.checked
    var url = checked ? url2 : url1

    // create new url with the value
    this.url = (`${url}`)
  }

  changeFrame(target) {
    // fetch turbo-type from the toggle
    const turboType = this.element.dataset.turboType

    // replace the turbo-frame with the new url
    let frame = document.querySelector(`turbo-frame#${turboType}`)
    frame.src = this.url
    frame.reload()
  }
}
