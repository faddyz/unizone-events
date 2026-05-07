import { Application } from "@hotwired/stimulus"

document.documentElement.classList.toggle("is-android", /Android/i.test(window.navigator.userAgent))

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }
