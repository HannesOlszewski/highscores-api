import { Controller } from "@hotwired/stimulus"

// Copies a snippet's text and briefly confirms on the button.
export default class extends Controller {
  static targets = [ "source", "button" ]

  async copy() {
    await navigator.clipboard.writeText(this.sourceTarget.textContent)

    const label = this.buttonTarget.textContent
    this.buttonTarget.textContent = "Copied"
    setTimeout(() => { this.buttonTarget.textContent = label }, 1500)
  }
}
