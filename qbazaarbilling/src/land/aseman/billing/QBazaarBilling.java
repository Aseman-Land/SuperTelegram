package land.aseman.billing;

import com.android.vending.billing.IInAppBillingService;
import android.os.Bundle;

public class QBazaarBilling {

    IInAppBillingService mService;

    public QBazaarBilling() {
        mService =
    }

    public IInAppBillingService getService() {
        return mService;
    }
}
