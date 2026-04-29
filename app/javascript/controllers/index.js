import { application } from "controllers/application"

import AccountMenuController from "controllers/account_menu_controller"
import AccordionController from "controllers/accordion_controller"
import AttendanceController from "controllers/attendance_controller"
import CarouselController from "controllers/carousel_controller"
import EventPreviewController from "controllers/event_preview_controller"
import ExploreFiltersController from "controllers/explore_filters_controller"
import HeroController from "controllers/hero_controller"
import NavbarController from "controllers/navbar_controller"
import ShareController from "controllers/share_controller"
import WizardController from "controllers/wizard_controller"

application.register("account-menu", AccountMenuController)
application.register("accordion", AccordionController)
application.register("attendance", AttendanceController)
application.register("carousel", CarouselController)
application.register("event-preview", EventPreviewController)
application.register("explore-filters", ExploreFiltersController)
application.register("hero", HeroController)
application.register("navbar", NavbarController)
application.register("share", ShareController)
application.register("wizard", WizardController)
