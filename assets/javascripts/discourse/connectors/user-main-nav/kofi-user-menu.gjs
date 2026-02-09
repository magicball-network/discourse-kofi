import Component from "@glimmer/component";
import { LinkTo } from "@ember/routing";
import { service } from "@ember/service";
import icon from "discourse/helpers/d-icon";
import { i18n } from "discourse-i18n";

export default class KofiUserMenu extends Component {
  @service currentUser;

  get viewingSelf() {
    return (
      this.currentUser &&
      this.currentUser.username.toLowerCase() ===
        this.args.model.username.toLowerCase()
    );
  }

  <template>
    {{#if this.viewingSelf}}
      <li class="user-nav__kofi">
        <LinkTo @route="user.ko-fi">
          {{icon "kofi"}}
          <span>{{i18n "discourse_kofi.title"}}</span>
        </LinkTo>
      </li>
    {{/if}}
  </template>
}
