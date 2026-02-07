import { tracked } from "@glimmer/tracking";
import Component from "@ember/component";
import { hash } from "@ember/helper";
import { LinkTo } from "@ember/routing";
import { service } from "@ember/service";
import icon from "discourse/helpers/d-icon";
import { ajax } from "discourse/lib/ajax";
import { i18n } from "discourse-i18n";

export default class BadgeRewardUsage extends Component {
  static shouldRender(args, { currentUser }) {
    return currentUser?.admin;
  }

  @service router;

  @tracked usedByReward = false;

  async init() {
    super.init(...arguments);
    await this.loadUsage();
  }

  async didUpdateAttrs() {
    super.didUpdateAttrs(...arguments);
    await this.loadUsage();
  }

  async loadUsage() {
    // Because this plugin outlet does not properly pass the badge instance
    let badgeId = this.router.currentRoute?.params["badge_id"];
    if (!badgeId) {
      return;
    }
    let rewards = await ajax("/ko-fi/admin/rewards/badge-usage", {
      method: "get",
      data: {
        id: badgeId,
      },
    }).then((result) => result.rewards);
    this.usedByReward = rewards && rewards.length > 0;
  }

  <template>
    {{#if this.usedByReward}}
      <div class="alert alert-warning">
        <LinkTo
          @route="adminPlugins.show.discourse-kofi-rewards"
          @model={{hash plugin_id="discourse-kofi"}}
        >
          {{icon "kofi-color"}}
          <span>{{i18n "discourse_kofi.rewards.warnings.badge-usage"}}</span>
        </LinkTo>
      </div>
    {{/if}}
  </template>
}
