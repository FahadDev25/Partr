import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="auto-print"
export default class extends Controller {
  connect() {
    // if(window.frames.pdf) {
    //   var pdfFrame = window.frames.pdf
    //   pdfFrame.addEventListener("load", async (event) => {
    //     pdfFrame.contentWindow.print();
    //   });
    //   const onFocus = () => {
    //     this.loadNext()
    //     window.removeEventListener("focus", onFocus)
    //   }
    //   window.addEventListener("focus", onFocus)
    // } else
    
    if (document.getElementById("image")){
      var image = document.getElementById("image")
      image.addEventListener("load", async (event) => {
        await this.pause(1000)
        window.print()
      });
      addEventListener("afterprint", async (event) => {
        this.loadNext()
      });
    } else {
      this.loadNext()
    }
  }

  async loadNext() {
    const url = this.element.dataset.url
    const turboType = this.element.dataset.turboType

    await this.pause(5000)

    // replace the turbo-frame with the new url
    let frame = document.querySelector(`turbo-frame#${turboType}`)
    frame.src = url
    frame.reload();
  }

  pause (milliseconds) {
    return new Promise((resolve) => setTimeout(function() { resolve(); }, milliseconds));
  }
}
