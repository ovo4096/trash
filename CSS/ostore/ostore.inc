#if defined _ostore_included_
  #endinput
#endif
#define _ostore_included_

#define OSTORE_PRODUCT_TYPE_AMOUNT			"amount"
#define OSTORE_PRODUCT_TYPE_VALIDITY		"validity"
#define OSTORE_PRODUCT_TYPE_FOREVER			"forever"

native bool:FindOStoreCategory(const String:name[], &Handle:hCategory=INVALID_HANDLE);
native bool:FindOStoreProduct(const String:name[], &Handle:hProduct=INVALID_HANDLE);
native bool:LinkOStoreProductToCategory(Handle:hProduct, Handle:hCategory);

native bool:RegOStoreCategory(const String:name[], const String:detail[], &Handle:hCategory=INVALID_HANDLE);
native bool:RegOStoreProduct(const String:name[], const String:detail[], &Handle:hProduct=INVALID_HANDLE);
native bool:RegOStoreProductType(Handle:hProduct, point, const String:type[]=OSTORE_PRODUCT_TYPE_FOREVER, amount=0, second=0, &Handle:hProductType=INVALID_HANDLE);

native bool:UnRegOStoreCategory(Handle:hCategory);
native bool:UnRegOStoreProduct(const Handle:hProduct);
native bool:UnRegOStoreProductType(Handle:hProductType);

native bool:UseOStoreProduct(client, Handle:hProduct);

native bool:IsOStoreAccountExist(client, &bool:isExist=false);
native bool:CreateOStoreAccount(client);
native bool:DeleteOStoreAccount(client);
native bool:SetOStoreAccountPoint(client, point);
native bool:GetOStoreAccountPoint(client, &point=0);
native bool:BuyOStoreProduct(client, Handle:hProductType);