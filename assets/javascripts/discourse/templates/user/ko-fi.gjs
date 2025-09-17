import RouteTemplate from "ember-route-template";
import DNavigationItem from "discourse/components/d-navigation-item";
import HorizontalOverflowNav from "discourse/components/horizontal-overflow-nav";
import bodyClass from "discourse/helpers/body-class";
import icon from "discourse/helpers/d-icon";
import { i18n } from "discourse-i18n";

export default RouteTemplate(
  <template>
    {{bodyClass "user-kofi-page"}}

    <div class="user-navigation user-navigation-secondary">
      <HorizontalOverflowNav
        @desktopClass="action-list nav-stacked"
        @currentPath={{@controller.router._router.currentPath}}
        class="activity-nav"
      >
        <DNavigationItem
          @route="user.ko-fi.payments"
          @ariaCurrentContext="subNav"
        >
          {{icon "far-credit-card"}}
          <span>{{i18n "discourse_kofi.user.navigation.payments"}}</span>
        </DNavigationItem>

        <DNavigationItem
          @route="user.ko-fi.accounts"
          @ariaCurrentContext="subNav"
        >
          {{icon "address-book"}}
          <span>{{i18n "discourse_kofi.user.navigation.accounts"}}</span>
        </DNavigationItem>

        <DNavigationItem @route="user.ko-fi.claim" @ariaCurrentContext="subNav">
          {{icon "plus"}}
          <span>{{i18n "discourse_kofi.user.navigation.claim"}}</span>
        </DNavigationItem>
      </HorizontalOverflowNav>
    </div>

    <section class="user-content">
      {{outlet}}
    </section>
  </template>
);
