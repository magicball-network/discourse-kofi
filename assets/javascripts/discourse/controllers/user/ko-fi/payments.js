import Controller from "@ember/controller";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { TrackedArray } from "@ember-compat/tracked-built-ins";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { i18n } from "discourse-i18n";
import UserPayment from "../../../models/user-payment";

export default class UserKofiPaymentsController extends Controller {
  @service dialog;

  queryParams = [{ initialSearch: "q" }];
  initialSearch = "";

  search = "";
  order = "timestamp";
  asc = null;
  period = "all";

  loading = false;

  _page = 1;
  _results = new TrackedArray();
  _canLoadMore = true;

  get payments() {
    return this._results.flat();
  }

  @action
  updatePeriod(period) {
    this.setProperties({ period });
    this.resetFilters();
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
    this._refreshPayments();
  }

  _refreshPayments() {
    if (!this._canLoadMore || this.loading) {
      return;
    }

    const page = this._page;
    this.set("loading", true);

    const { startDate, endDate } = this._computePeriod();

    UserPayment.findAll({
      search: this.search,
      order: this.order,
      asc: this.asc,
      page,
      startDate,
      endDate,
    })
      .then((result) => {
        this._results[page] = result.payments;
        if (result.length === 0) {
          this._canLoadMore = false;
        }
      })
      .finally(() => {
        this.set("loading", false);
      });
  }

  _computePeriod() {
    const endDate = moment().locale("en").utc().endOf("day");
    let startDate = moment().locale("en").utc().startOf("day");
    switch (this.period) {
      case "all":
        return { startDate: null, endDate: null };
      case "yearly":
        startDate.subtract(1, "year");
        break;
      case "quarterly":
        startDate.subtract(3, "month");
        break;
      case "weekly":
        startDate.subtract(6, "days");
        break;
      case "daily":
        // no change
        break;
      case "monthly":
      // falls through
      default:
        startDate.subtract(1, "month");
        break;
    }
    return {
      startDate: startDate.toISOString(),
      endDate: endDate.toISOString(),
    };
  }

  @action
  loadMore() {
    if (this.loading) {
      return;
    }
    this._page += 1;
    this._refreshPayments();
  }

  @action
  hidePayment(payment) {
    const performHide = () => {
      payment.hidePayment().catch(popupAjaxError);
    };

    this.dialog.confirm({
      title: i18n("discourse_kofi.payments.actions.make_private.title"),
      message: i18n(
        "discourse_kofi.payments.actions.make_private.confirmation"
      ),
      class: "hide-kofi-payment-modal",
      confirmButtonIcon: "eye-slash",
      confirmButtonLabel:
        "discourse_kofi.payments.actions.make_private.confirm",
      didConfirm: performHide,
    });
  }
}
