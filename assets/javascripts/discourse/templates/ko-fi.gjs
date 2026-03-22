import Component from "@glimmer/component";
import { concat } from "@ember/helper";
import { htmlSafe } from "@ember/template";
import UserAvatar from "discourse/components/user-avatar";
import UserLink from "discourse/components/user-link";
import icon from "discourse/helpers/d-icon";
import formatDate from "discourse/helpers/format-date";
import { and, lt } from "discourse/truth-helpers";
import I18n, { i18n } from "discourse-i18n";

export default class extends Component {
  getAvatarSize(idx) {
    return idx < 1 ? "medium" : "small";
  }

  formatGoalProgress(goal) {
    if (goal.target) {
      return I18n.messageFormat("discourse_kofi.dashboard.goal.target_MF", {
        progress: goal.progress,
        target: goal.target,
      });
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
              style={{htmlSafe (concat "--progress: " @model.goal.progress)}}
            >
              <circle class="border"></circle>
              <circle class="bg"></circle>
              <circle class="progress"></circle>
              <text
                x="50%"
                y="55%"
                class="progress"
              >{{@model.goal.progress}}%</text>
              <text
                x="50%"
                y="70%"
                class="goal-target"
              >{{this.formatGoalProgress @model.goal}}</text>
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
                    <UserLink
                      @user={{entry.user}}
                    >{{entry.user.username}}</UserLink>
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
          <h2>{{i18n "discourse_kofi.dashboard.payments.title"}}</h2>
          <div class="kofi_dashboard__payments_list">
            {{#each @controller.payments as |payment|}}
              <div class="kofi_dashboard__payments_payment">
                <div class="kofi_dashboard__payments_payment_timestamp">
                  {{formatDate payment.timestamp leaveAgo="true"}}
                </div>
                <div class="kofi_dashboard__payments_payment_user">
                  {{#if payment.user}}
                    <UserAvatar @size="tiny" @user={{payment.user}} />
                    <UserLink
                      @user={{payment.user}}
                    >{{payment.user.username}}</UserLink>
                  {{else if payment.username}}
                    {{payment.username}}
                  {{else}}
                    {{icon "user-secret"}}
                    {{i18n "discourse_kofi.anonymous"}}
                  {{/if}}
                </div>
                {{#if payment.amount_currency}}
                  <div class="kofi_dashboard__payments_payment_amount">
                    {{payment.amount_currency}}
                  </div>
                {{/if}}
                <div class="kofi_dashboard__payments_payment_message">
                  {{payment.message}}
                </div>
              </div>
            {{/each}}
          </div>
        </div>
      {{/if}}

    </section>
  </template>
}
