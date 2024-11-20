// app/javascript/controllers/radio_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["option"]

  select(event) {
    this.optionTargets.forEach((element) => {
      element.classList.remove("selected")
    })
    event.currentTarget.classList.add("selected")
    event.currentTarget.querySelector("input[type='radio']").checked = true
  }
}
