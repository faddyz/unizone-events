// Import and register all your controllers from @stimulus/core
import { application } from "./application"

// Eager load all controllers defined in the import map under controllers/**/*_controller
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)

// Register the dropdown controller
import DropdownController from "./dropdown_controller"
application.register("dropdown", DropdownController)

// Register the delete confirmation controller
import DeleteConfirmationController from "./delete_confirmation_controller"
application.register("delete-confirmation", DeleteConfirmationController)
