import Component from "@glimmer/component";
import { concat } from "@ember/helper";
import { htmlSafe } from "@ember/template";
import UserAvatar from "discourse/components/user-avatar";
import icon from "discourse/helpers/d-icon";
import { and, lt } from "discourse/truth-helpers";
import I18n, { i18n } from "discourse-i18n";

export default class extends Component {
  getAvatarSize(idx) {
    return idx < 1 ? "medium" : "small";
  }

  formatGoalProgress(goal) {
    if (goal.target) {
      return I18n.messageFormat(
        "discourse_kofi.dashboard.goal.target_MF",
        {
          progress: goal.progress,
          target: goal.target,
        }
      );
    } else {
      return "";
    }
  }

  <template>
    <section class="container">
      <div class="contents clearfix body-page kofi_dashboard__main">
        {{htmlSafe @controller.donationMessage.html}}
      </div>
    </section>

    <section class="kofi_dashboard__sections">

      {{#if
        (and
          @controller.siteSettings.kofi_dashboard_widget_enabled
          @controller.siteSettings.kofi_account
        )
      }}
        <div class="kofi_dashboard__widget">
          <iframe
            title="Ko-fi Donation"
            loading="lazy"
            src="https://ko-fi.com/{{@controller.siteSettings.kofi_account}}/?hidefeed=true&widget=true&embed=true&preview=true"
            height="570"
          ></iframe>
        </div>
      {{/if}}

      {{#if @model.goal}}
        <div class="kofi_dashboard__goal">
          <h2>{{i18n "discourse_kofi.dashboard.goal.title"}}</h2>
          <div class="kofi_dashboard__goal_container">
            <svg
              width="250"
              height="250"
              viewBox="0 0 250 250"
              class="kofi_dashboard__goal_bar"
              style={{htmlSafe
                (concat "--progress: " @model.goal.progress)
              }}
            >
              <circle class="border"></circle>
              <circle class="bg"></circle>
              <circle class="fg"></circle>
              <text x="50%" y="55%" class="progress">{{@model.goal.progress}}%</text>
              <text x="50%" y="70%" class="goal-target">{{this.formatGoalProgress @model.goal}}</text>
            </svg>
          </div>
        </div>
      {{/if}}

      {{#if @model.leaderboard}}
        <div class="kofi_dashboard__leaderboard">
          <h2>{{i18n "discourse_kofi.dashboard.leaderboard.title"}}</h2>
          <ol>
            {{#each @model.leaderboard as |entry idx|}}
              <li class="leaderboard{{idx}}">
                {{#if (lt idx 3)}}
                  <span class="kofi_dashboard__leaderboard_trophy">{{icon
                      "trophy"
                    }}</span>
                {{/if}}
                <span class="kofi_dashboard__leaderboard_user">
                  {{#if entry.user}}
                    <UserAvatar
                      @size={{this.getAvatarSize idx}}
                      @user={{entry.user}}
                    />
                    {{entry.user.username}}
                  {{else if entry.name}}
                    {{entry.name}}
                  {{else}}
                    {{icon "user-secret"}}
                    {{i18n "discourse_kofi.anonymous"}}
                  {{/if}}
                </span>
              </li>
            {{/each}}
          </ol>
        </div>
      {{/if}}

      {{#if @controller.siteSettings.kofi_dashboard_count}}
        <div class="kofi_dashboard__payments">
          This will contain the most recent payments made by users with their
          message and what not.
        </div>
      {{/if}}

    </section>
  </template>
}
