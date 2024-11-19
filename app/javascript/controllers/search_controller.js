import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  submit(event) {
    if (event.key === "Enter") {
      event.preventDefault()
      event.target.form.requestSubmit()
    }
  }
} 