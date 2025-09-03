import Controller from "@ember/controller";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { TrackedArray } from "@ember-compat/tracked-built-ins";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { i18n } from "discourse-i18n";
import AdminAccount from "../../../models/admin-account";

export default class AdminPluginsShowDiscourseKofiAccountsController extends Controller {
  @service dialog;
  @service toasts;

  queryParams = [{ initialSearch: "q" }];
  initialSearch = "";

  search = "";
  order = "created_at";
  asc = null;

  loading = false;

  emailsVisible = false;

  _page = 1;
  _results = new TrackedArray();
  _canLoadMore = true;

  get accounts() {
    return this._results.flat();
  }

  @action
  toggleEmailVisible() {
    this.set("emailsVisible", !this.get("emailsVisible"));
  }

  @action
  updateSearch(search) {
    this.setProperties({ search });
    this.resetFilters();
  }

  @action
  updateOrder(order, asc) {
    this.setProperties({
      order,
      asc,
    });
    this.resetFilters();
  }

  @action
  toggleBulkSelect() {}

  resetFilters() {
    this._page = 1;
    this._results.length = 0;
    this._canLoadMore = true;
    this._refreshAccounts();
  }

  _refreshAccounts() {
    if (!this._canLoadMore || this.loading) {
      return;
    }

    const page = this._page;
    this.set("loading", true);

    AdminAccount.findAll({
      search: this.search,
      order: this.order,
      asc: this.asc,
      page,
    })
      .then((result) => {
        this._results[page] = result.accounts;
        if (result.length === 0) {
          this._canLoadMore = false;
        }
      })
      .finally(() => {
        this.set("loading", false);
      });
  }

  @action
  loadMore() {
    if (this.loading) {
      return;
    }
    this._page += 1;
    this._refreshAccounts();
  }

  @action
  toggleAlwaysHide(account) {
    account
      .toggleAlwaysHide()
      .then(() => {
        this.toasts.success({
          data: {
            message: i18n(
              account.alwaysHide
                ? "discourse_kofi.accounts.actions.not_always_hide.updated"
                : "discourse_kofi.accounts.actions.always_hide.updated",
              account
            ),
          },
        });
      })
      .catch(popupAjaxError);
  }

  @action
  makePaymentsNotPublic(account) {
    const hidePayments = () => {
      account
        .hidePayments()
        .then(() => {
          this.toasts.success({
            data: {
              message: i18n(
                "discourse_kofi.accounts.actions.hide_payment_details.updated",
                account
              ),
            },
          });
        })
        .catch(popupAjaxError);
    };

    this.dialog.confirm({
      title: i18n("discourse_kofi.accounts.actions.hide_payment_details.title"),
      message: i18n(
        "discourse_kofi.accounts.actions.hide_payment_details.confirmation",
        account
      ),
      confirmButtonIcon: "eye-slash",
      confirmButtonLabel:
        "discourse_kofi.accounts.actions.hide_payment_details.confirm",
      didConfirm: hidePayments,
    });
  }

  @action
  makeAnonymous(account) {
    const performAnonymize = () => {
      account
        .anonymize()
        .then(() => {
          this.toasts.success({
            data: {
              message: i18n(
                "discourse_kofi.accounts.actions.anonymize.anonymized",
                account
              ),
            },
          });
        })
        .catch(popupAjaxError);
    };

    this.dialog.confirm({
      title: i18n("discourse_kofi.accounts.actions.anonymize.title"),
      message: i18n("discourse_kofi.accounts.actions.anonymize.confirmation", {
        email: account.email,
        username: account.user.username,
      }),
      confirmButtonIcon: "user-secret",
      confirmButtonLabel: "discourse_kofi.accounts.actions.anonymize.confirm",
      confirmButtonClass: "btn-danger",
      didConfirm: performAnonymize,
    });
  }

  @action
  delete(account) {
    const performDelete = () => {
      account
        .delete()
        .then(() => {
          this.toasts.success({
            data: {
              message: i18n("discourse_kofi.accounts.actions.delete.deleted"),
              account,
            },
          });
          this.resetFilters();
        })
        .catch(popupAjaxError);
    };

    this.dialog.confirm({
      title: i18n("discourse_kofi.accounts.actions.delete.title"),
      message: i18n("discourse_kofi.accounts.actions.delete.confirmation", {
        username: account.user.username,
      }),
      confirmButtonIcon: "trash-can",
      confirmButtonLabel: "discourse_kofi.accounts.actions.delete.confirm",
      confirmButtonClass: "btn-danger",
      didConfirm: performDelete,
    });
  }
}
