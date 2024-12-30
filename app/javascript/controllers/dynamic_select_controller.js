import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dynamic-select"
export default class extends Controller {
  static targets = ["select"]
  connect() {}
  
  selectTargetConnected(element) {
    element.dataset.action = 'change->dynamic-select#change'
    this.change({ target: element })
  }

  change(event) {
    // get value of the triggering element
    const value = event.target.value
    const altValue = event.target.dataset.altValue
    // preset value for target element
    const preset = event.target.dataset.preset
    // the class of the object the select list is being created for
    const object = event.target.dataset.object
    // for additional filter
    const filter = event.target.dataset.filter
    // edit or new
    const mode = event.target.dataset.mode

    // get data-url from the select
    const url = event.target.dataset.url
    const altUrl = event.target.dataset.altUrl
    // fetch turbo-type from the select
    const turboType = event.target.dataset.turboType
    // create params string
    const params = new URLSearchParams({
      value: value,
      alt_value: altValue,
      object: object,
      preset: preset,
      filter: filter,
      mode: mode,
      alt_url: altUrl
    });

    // Get data for the target frame
    let frame = document.querySelector(`turbo-frame#${turboType}`)
    let select = frame.querySelector('select')
    let selectData = select.dataset

    // If the target is also a selectTarget, add its data to the params
    if (selectData.dynamicSelectTarget != null) {
      params.append("child_preset", selectData.preset) 
      params.append("turbo_type", selectData.turboType)
      params.append("url", selectData.url)
      params.append("target", selectData.dynamicSelectTarget)
      params.append("alt_value", selectData.altValue)
      params.append("alt_url", selectData.altUrl)
      params.append("filter", selectData.filter)
      params.append("mode", selectData.mode)
    }

    // create new url with the value
    this.url = (`${url}?${params}`)

    // replace the turbo-frame with the new url
    frame.src = this.url
    frame.reload();
  }
}
