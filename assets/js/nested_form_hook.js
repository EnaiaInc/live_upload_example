export const NestedForm = {
  actualForm: null,

  mounted() {
    this.actualForm = this.createFormElement()
    document.getElementById("all-nested-forms").appendChild(this.actualForm)

    this.el.addEventListener("keypress", (e) => {
      if (e.key === "Enter" && this.implicitSubmit(e.target)) {
        e.preventDefault()
        this.actualForm.requestSubmit()
      }
    })
  },

  destroyed() {
    this.actualForm.remove()
  },

  createFormElement() {
    const data = JSON.parse(this.el.dataset.nestedForm)

    const form = document.createElement("form")
    for (const attr in data) form.setAttribute(attr, data[attr])

    return form
  },

  // Returns if `this.actualForm` should be implicitly submitted
  // Apparently the browsers (at least Firefox) do not support with `form=...`
  // See:
  // https://www.w3.org/TR/2011/WD-html5-20110525/association-of-controls-and-forms.html#implicit-submission

  // For simplicity, we assume no `<input type="submit">`. Use `<button type="submit">` instead
  implicitSubmit(target) {
    return (
      target.getAttribute("form") === this.actualForm.id &&
      document.querySelectorAll(`input[form="${this.actualForm.id}"]`).length <=
        1 &&
      document.querySelectorAll(`button[form="${this.actualForm.id}"]`)
        .length === 0
    )
  },
}
