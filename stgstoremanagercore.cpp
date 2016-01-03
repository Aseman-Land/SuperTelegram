#include "stgstoremanagercore.h"
#include "asemantools/asemanapplication.h"

class StgStoreManagerCorePrivate
{
public:
};

StgStoreManagerCore::StgStoreManagerCore(QObject *parent) :
    AsemanStoreManager(parent)
{
    p = new StgStoreManagerCorePrivate;

#if defined(STG_STORE_BAZAAR)
    setPublicKey("MIHNMA0GCSqGSIb3DQEBAQUAA4G7ADCBtwKBrwCq+c11JIpuX0LZ2yzn7gDofHRzyFP1JMv2Vh+fG9UbYbH/kCRSBtkGaZvycrgdozPh5nxgLBb4RQlMuSv3Aozc+tQSt2N8Lxid81VV3n26BeCYQkgKt8yIXFwMFNa0/BIHrxCYbhHZsBx/3JfG7UMkjEXTxsiTjLGG5ntGV9WR3IlbX1q294BlGwG7fbHxMYoKuRN6SOSJX0wCnN4+JpwZTwJZYebhd7j+Zi7J/ycCAwEAAQ==");
    setPackageName("com.farsitel.bazaar");
    setBindIntent("ir.cafebazaar.pardakht.InAppBillingService.BIND");
#elif defined(STG_STORE_GOOGLE)
#endif

    setCacheSource( AsemanApplication::homePath() + "/store.cache");
    setup();
}

StgStoreManagerCore::~StgStoreManagerCore()
{
    delete p;
}

