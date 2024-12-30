import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="clipboard-copy"
export default class extends Controller {
  static targets = [ "source", "copyButton" ]
  connect() {
    this.copyButtonTarget.dataset.action = "click->clipboard-copy#copy"
  }

  copy() {
    navigator.clipboard.writeText(this.sourceTarget.innerText)
    this.copyButtonTarget.innerText = "\u2713"
  }
}
