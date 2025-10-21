import Component from "@ember/component";
import { LinkTo } from "@ember/routing";
import { service } from "@ember/service";
import { classNames, tagName } from "@ember-decorators/component";
import icon from "discourse/helpers/d-icon";
import { i18n } from "discourse-i18n";

@tagName("li")
@classNames("user-main-nav-outlet")
export default class KofiUserMenu extends Component {
  @service currentUser;

  get viewingSelf() {
    return (
      this.currentUser &&
      this.currentUser.username.toLowerCase() ===
        this.outletArgs.model.username.toLowerCase()
    );
  }

  <template>
    {{#if this.viewingSelf}}
      <LinkTo @route="user.ko-fi">
        {{icon "kofi"}}
        <span>{{i18n "discourse_kofi.title"}}</span>
      </LinkTo>
    {{/if}}
  </template>
}
