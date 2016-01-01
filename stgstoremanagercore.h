#ifndef STGSTOREMANAGERCORE_H
#define STGSTOREMANAGERCORE_H

#include "asemantools/asemanstoremanager.h"

class StgStoreManagerCorePrivate;
class StgStoreManagerCore : public AsemanStoreManager
{
    Q_OBJECT
public:
    StgStoreManagerCore(QObject *parent = 0);
    ~StgStoreManagerCore();

    DEFINE_STORE_MANAGER_INVENTORY(stg_premium_pack)
    DEFINE_STORE_MANAGER_INVENTORY(stg_sens_msg_3plus)
    DEFINE_STORE_MANAGER_INVENTORY(stg_txt_tags)
    DEFINE_STORE_MANAGER_INVENTORY(stg_ppic_unlimit_plus)
    DEFINE_STORE_MANAGER_INVENTORY(stg_by_stg)

private:
    StgStoreManagerCorePrivate *p;
};

#endif // STGSTOREMANAGERCORE_H
