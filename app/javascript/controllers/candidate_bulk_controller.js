import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["bar", "checkbox", "count", "row", "selectAll"]

  connect() {
    this.update()
  }

  update() {
    const selectedCount = this.checkboxTargets.filter((checkbox) => checkbox.checked).length

    this.countTarget.textContent = selectedCount
    this.barTarget.classList.toggle("hidden", selectedCount === 0)
    this.rowTargets.forEach((row) => {
      const checkbox = row.querySelector("input[type='checkbox']")
      row.classList.toggle("is-selected", checkbox?.checked)
    })

    if (this.hasSelectAllTarget) {
      this.selectAllTarget.checked = selectedCount > 0 && selectedCount === this.checkboxTargets.length
      this.selectAllTarget.indeterminate = selectedCount > 0 && selectedCount < this.checkboxTargets.length
    }
  }

  toggleRow(event) {
    if (event.target.closest("a, button, input, label, select, textarea")) return

    const checkbox = event.currentTarget.querySelector("input[type='checkbox']")
    if (!checkbox) return

    checkbox.checked = !checkbox.checked
    this.update()
  }

  toggleAll() {
    const checked = this.selectAllTarget.checked
    this.checkboxTargets.forEach((checkbox) => {
      checkbox.checked = checked
    })

    this.update()
  }

  clear() {
    this.checkboxTargets.forEach((checkbox) => {
      checkbox.checked = false
    })

    this.update()
  }
}
