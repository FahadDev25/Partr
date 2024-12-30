import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search-filter"
export default class extends Controller {
  static targets = [ "search", "filter", "range", "date", "apply", "reset", "clearSearch", "toggle" ]
  connect() {
    this.searchTarget.dataset.action = 'input->search-filter#get_results'
    this.filterTargets.forEach(element => {
      element.dataset.action = 'input->search-filter#get_results'
    })
    this.rangeTargets.forEach(element => {
      element.dataset.action = 'input->search-filter#get_results'
    })
    this.dateTargets.forEach(element => {
      element.dataset.action = 'input->search-filter#get_results'
    })
    this.applyTarget.dataset.action = 'click->search-filter#get_results'
    this.resetTarget.dataset.action = 'click->search-filter#reset_filters'
    this.clearSearchTarget.dataset.action = 'click->search-filter#clear_search'
    
    addEventListener("popstate", (event) => { 
      if (["/parts","/assemblies", "/manufacturers", "/vendors", "/customers", "/teams/jobs", "/teams/orders", "/teams/shipments", "/users", "/teams"].includes(location.pathname.replace(/\/[0-9]+/,""))) {
        location.reload()
        // Turbo.visit(location.href, { frame: this.element.dataset.turboType });
        // Turbo.visit(location.href, { frame: "search_and_filters" });
        // let frame = document.querySelector(`turbo-frame#search_and_filters`)
        // if (frame != null) {
        //   frame.src = this.element.dataset.url + "&format=turbo_stream"
        //   frame.reload
        // }
        // let modal_close = document.querySelector('[aria-label="close"]')
        // if (modal_close != null) { modal_close.click() }
      }
    });
    addEventListener("turbo:before-frame-render", (event) => {
      if (["/parts","/assemblies", "/manufacturers", "/vendors", "/customers", "/teams/jobs", "/teams/orders", "/teams/shipments", "/users", "/teams"].includes(location.pathname.replace(/\/[0-9]+/,""))) {
        let changedFrame = event.detail.newFrame
        let frame = document.querySelector(`turbo-frame#${this.element.dataset.turboType}`)
        if (changedFrame.id == frame?.id && frame?.src != location.href) {
            history.pushState({}, "", frame.src);
        };
      }
    });
  }

  get_results() {
    // get value of search from searchbox
    const search = this.searchTarget.value.toString()
    // get url data-url from element
    const turboType = this.element.dataset.turboType

    // initialize variable to hold params to send to the the url
    var params = ''
    // initialize variable to hold the filters
    var filters = new Array()

    // add search to the filter array for convenience when writing the param string
    if (search != ''){
      filters.push(['query', search])
    };

    // add non-empty filters to the filter array
    this.filterTargets.forEach(element => {
      if (element.value != '') {
        filters.push([element.id, element.value])
      }
    });

    // add range filters to the filter array
    this.rangeTargets.forEach(element=> {
      var column = element.dataset.column
      var min = element.querySelector(`#${column}_min`).value
      var max = element.querySelector(`#${column}_max`).value
      if ("round" in element.dataset) {
        if (min != ''){ min = element.querySelector(`#${column}_min`).value = Math.round(min) }
        if (max != ''){ max = element.querySelector(`#${column}_max`).value = Math.round(max) }
      }
      if (min != '' || max != '') {
        filters.push([column, `${min}to${max}`])
      }
    });

    // add date filters to the filter array
    this.dateTargets.forEach(element=> {
      var column = element.dataset.column
      var start = element.querySelector(`#${column}_start`).value
      var end = element.querySelector(`#${column}_end`).value
      if (start != '' || end != '') {
        filters.push([column, `${start}to${end}`])
      }
    });

    // build the param string from the filter array
    params = new URLSearchParams(filters)

    if (params.size > 0) {
      params = "?" + params.toString()
    } else {
      params = ""
    }

    // go to url with new params changing only the target turbo frame
    const newUrl = `${location.origin}${location.pathname}${params}`;

    Turbo.visit(newUrl, { frame: turboType });

    const toggle = this.toggleTarget
    var current_params = toggle.href.split("?")[1].split("&")
    const kept_params = current_params.filter((param)=> param.includes("filter") || param.includes("target=") || param.includes("format="))
    
    toggle.href = toggle.href.split("?")[0] + "?" + kept_params.join("&") + "&" + params.replace("?", "")
  }

  reset_filters() {
    // remove all filters and reload
    this.filterTargets.forEach(element => {
      if (element.tagName == "INPUT") {
        element.value = ''
      } else if (element.tagName == "SELECT") {
        element.selectedIndex = 0
      }
    })
    this.rangeTargets.forEach(element=> {
      var column = element.dataset.column
      element.querySelector(`#${column}_min`).value = ''
      element.querySelector(`#${column}_max`).value = ''
    })
    this.dateTargets.forEach(element=> {
      var column = element.dataset.column
      element.querySelector(`#${column}_start`).value = ''
      element.querySelector(`#${column}_end`).value = ''
    })
    this.get_results()
  }

  clear_search() {
    // remove search and reload
    this.searchTarget.value = ''
    this.get_results()
  }
}
