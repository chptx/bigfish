package order;

import java.util.List;

import org.apache.commons.lang.StringUtils;
import org.ofbiz.base.util.UtilProperties;
import org.ofbiz.order.order.OrderReadHelper;
import org.ofbiz.party.contact.ContactHelper;
import org.ofbiz.entity.condition.EntityCondition;
import org.ofbiz.entity.condition.EntityOperator;
import org.ofbiz.entity.util.EntityUtil;
import org.ofbiz.party.contact.ContactMechWorker;
import org.ofbiz.base.util.UtilValidate;
import org.ofbiz.base.util.UtilMisc;
import org.ofbiz.product.product.ProductContentWrapper;
import org.ofbiz.entity.GenericValue;
import org.ofbiz.base.util.string.FlexibleStringExpander;
import javolution.util.FastList;
import javolution.util.FastMap;
import org.ofbiz.entity.condition.EntityFunction;

userLogin = session.getAttribute("userLogin");
orderId = StringUtils.trimToEmpty(parameters.orderId);
context.orderId = orderId;

orderHeader = null;
orderItems = null;
orderNotes = null;
partyId = null;
shipGroup = null;

orderSubTotal = 0;
if (UtilValidate.isNotEmpty(orderId))
{
	orderHeader = delegator.findByPrimaryKey("OrderHeader", [orderId : orderId]);
	
	orderProductStore = orderHeader.getRelatedOne("ProductStore");
	if (UtilValidate.isNotEmpty(orderProductStore.storeName))
	{
		productStoreName = orderProductStore.storeName;
	}
	else
	{
		productStoreName = orderHeader.productStoreId;
	}
	context.productStoreName = productStoreName;
	
	messageMap=[:];
	messageMap.put("orderId", orderId);

	context.orderId=orderId;
	context.pageTitle = UtilProperties.getMessage("OSafeAdminUiLabels","OrderManagementOrderDetailTitle",messageMap, locale )
	context.generalInfoBoxHeading = UtilProperties.getMessage("OSafeAdminUiLabels","OrderDetailInfoHeading",messageMap, locale )
	
}

orderHeaderAdjustments = null;
if (UtilValidate.isNotEmpty(orderHeader))
{
	productStore = orderHeader.getRelatedOne("ProductStore");
	orderReadHelper = new OrderReadHelper(orderHeader);
	orderItems = orderReadHelper.getOrderItems();
	canceledPromoOrderItem = [:];
	orderItems.each { orderItem ->
		if("Y".equals(orderItem.get("isPromo")) && "ITEM_CANCELLED".equals(orderItem.get("statusId")))
		{
			canceledPromoOrderItem = orderItem;
		}
		orderItems.remove(canceledPromoOrderItem);
	}
	orderSubTotal = orderReadHelper.getOrderItemsSubTotal();
	orderAdjustments = orderReadHelper.getAdjustments();
	otherAdjustmentsList = FastList.newInstance();
	otherAdjustmentsList = EntityUtil.filterByAnd(orderAdjustments, [EntityCondition.makeCondition("orderAdjustmentTypeId", EntityOperator.NOT_EQUAL, "PROMOTION_ADJUSTMENT")]);
	otherAdjustmentsAmount = OrderReadHelper.calcOrderAdjustments(otherAdjustmentsList, orderSubTotal, true, false, false);
	orderHeaderAdjustments = orderReadHelper.getOrderHeaderAdjustments();
	headerAdjustmentsToShow = orderReadHelper.filterOrderAdjustments(orderHeaderAdjustments, true, false, false, false, false);
	shippingAmount = OrderReadHelper.getAllOrderItemsAdjustmentsTotal(orderItems, orderAdjustments, false, false, true);
	shippingAmount = shippingAmount.add(OrderReadHelper.calcOrderAdjustments(orderHeaderAdjustments, orderSubTotal, false, false, true));
	orderItemShipGroups = orderReadHelper.getOrderItemShipGroups();
	headerAdjustmentsToShow = orderReadHelper.getOrderHeaderAdjustmentsToShow();
	taxAmount = OrderReadHelper.getOrderTaxByTaxAuthGeoAndParty(orderAdjustments).taxGrandTotal;
	
	grandTotal = orderReadHelper.getOrderGrandTotal();
	currencyUomId = orderReadHelper.getCurrency();
}

context.shippingAmount = shippingAmount;
context.taxAmount = taxAmount;
context.otherAdjustmentsAmount = otherAdjustmentsAmount;
context.grandTotal = grandTotal;
context.currencyUomId = currencyUomId;

appliedTaxList = FastList.newInstance();
List orderShipTaxAdjustments = FastList.newInstance();
totalTaxPercent = 0;
if(UtilValidate.isNotEmpty(orderAdjustments) && orderAdjustments.size() > 0)
{
	orderShipTaxAdjustments = EntityUtil.filterByAnd(orderAdjustments, UtilMisc.toMap("orderAdjustmentTypeId", "SALES_TAX"));
	
	for (GenericValue orderTaxAdjustment : orderShipTaxAdjustments)
	{
		amount = 0;
		taxAuthorityRateSeqId = orderTaxAdjustment.taxAuthorityRateSeqId;
		if(UtilValidate.isNotEmpty(taxAuthorityRateSeqId))
		{
			//check if this taxAuthorityRateSeqId is already in the list
			alreadyInList = "N";
			for(Map taxInfoMap : appliedTaxList)
			{
				taxAuthorityRateSeqIdInMap = taxInfoMap.get("taxAuthorityRateSeqId");
				if(UtilValidate.isNotEmpty(taxAuthorityRateSeqIdInMap) && taxAuthorityRateSeqIdInMap.equals(taxAuthorityRateSeqId))
				{
					amount = taxInfoMap.get("amount") + orderTaxAdjustment.amount;
					taxInfoMap.put("amount", amount);
					alreadyInList = "Y";
					break;
				}
			}
			if(("N").equals(alreadyInList))
			{
				taxInfo = FastMap.newInstance();
				taxInfo.put("taxAuthorityRateSeqId", taxAuthorityRateSeqId);
				taxInfo.put("amount", orderTaxAdjustment.amount);
				taxInfo.put("sourcePercentage", orderTaxAdjustment.sourcePercentage);
				taxInfo.put("description", orderTaxAdjustment.comments);
				appliedTaxList.add(taxInfo);
				totalTaxPercent = totalTaxPercent + orderTaxAdjustment.sourcePercentage;
			}
		}
	}
}
context.appliedTaxList = appliedTaxList;
context.totalTaxPercent = totalTaxPercent;

//get Promo Text
appliedPromoList = FastList.newInstance();
if(UtilValidate.isNotEmpty(headerAdjustmentsToShow) && headerAdjustmentsToShow.size() > 0)
{
	adjustments = headerAdjustmentsToShow;
	for (GenericValue cartAdjustment : adjustments)
	{
		promoInfo = FastMap.newInstance();
		promoInfo.put("cartAdjustment", cartAdjustment);
		promoCodeText = "";
		adjustmentType = cartAdjustment.getRelatedOne("OrderAdjustmentType");
		adjustmentTypeDesc = adjustmentType.get("description",locale);
		promoInfo.put("adjustmentTypeDesc", adjustmentTypeDesc);
		productPromo = cartAdjustment.getRelatedOne("ProductPromo");
		if(UtilValidate.isNotEmpty(productPromo))
		{
			promoText = productPromo.promoText;
			promoInfo.put("promoText", promoText);
			productPromoCode = productPromo.getRelated("ProductPromoCode");
			if(UtilValidate.isNotEmpty(productPromoCode))
			{
				promoCodesEntered = orderReadHelper.getProductPromoCodesEntered();
				if(UtilValidate.isNotEmpty(promoCodesEntered))
				{
					for (GenericValue promoCodeEntered : promoCodesEntered)
					{
						if(UtilValidate.isNotEmpty(promoCodeEntered))
						{
							for (GenericValue promoCode : productPromoCode)
							{
								promoCodeEnteredId = promoCodeEntered;
								promoCodeId = promoCode.productPromoCodeId;
								if(UtilValidate.isNotEmpty(promoCodeEnteredId))
								{
									if(promoCodeId == promoCodeEnteredId)
									{
										promoCodeText = promoCode.productPromoCodeId;
										promoInfo.put("promoCodeText", promoCodeText);
									}
								}
							}
						}
					}
					
				}
			}
		}
		appliedPromoList.add(promoInfo);
	}
}


//Promo
context.appliedPromoList = appliedPromoList;
//Sub Total
context.orderSubTotal = orderSubTotal;


if (UtilValidate.isNotEmpty(orderHeader)) 
{
	// note these are overridden in the OrderViewWebSecure.groovy script if run
	context.hasPermission = true;
	context.canViewInternalDetails = true;

	orderReadHelper = new OrderReadHelper(orderHeader);
	orderItems = orderReadHelper.getOrderItems();

	context.orderHeader = orderHeader;
	context.orderReadHelper = orderReadHelper;
	context.orderItems = orderItems;
	
	notes = orderHeader.getRelatedOrderBy("OrderHeaderNoteView", ["-noteDateTime"]);
	context.orderNotes = notes;

}	
	
//FOR EACH INDIVIDUAL ORDER ITEM SCREEN	
itemCancelledAmmount = 0;
orderItem = request.getAttribute("orderItem");
if(UtilValidate.isNotEmpty(orderItem))
{
	context.orderItem = orderItem;
	orderItemSeqId = orderItem.orderItemSeqId;
	messageMap=[:];
	messageMap.put("orderItemSeqId", orderItemSeqId);

	context.orderId=orderId;
	context.orderItemBoxHeading = UtilProperties.getMessage("OSafeAdminUiLabels","OrderItemBoxHeading",messageMap, locale )
	
	statusItem = orderItem.getRelatedOne("StatusItem");
	context.statusItem = statusItem;
	
	//get Returned Quantity
	if(UtilValidate.isNotEmpty(orderHeader) && UtilValidate.isNotEmpty(orderReadHelper))
	{
		if("SALES_ORDER".equals(orderHeader.orderTypeId))
		{
			pickedQty = orderReadHelper.getItemPickedQuantityBd(orderItem);
			context.pickedQty = pickedQty;
		}
		
		// QUANTITY: get the returned quantity by order item map
		context.returnQuantityMap = orderReadHelper.getOrderItemReturnedQuantities();
	}
	
	//get cancelled quantity
	if("ITEM_CANCELLED".equals(orderItem.get("statusId")))
	{
		itemCancelledAmmount = orderItem.quantity;
	}
	
	//get shipGroup	
	shipDate = "";
	carrier = "";
	orderItemShipGroupAddress = null;
	orderItemShipDate = null;
	orderItemCarrier = null;
	orderItemTrackingNo = null;
	orderItemShipGroupAssocs = orderItem.getRelated("OrderItemShipGroupAssoc");
	if(UtilValidate.isNotEmpty(orderItemShipGroupAssocs))
	{
		for (GenericValue shipGroupAssoc: orderItemShipGroupAssocs)
		{
			if(UtilValidate.isNotEmpty(shipGroupAssoc.getRelatedOne("OrderItemShipGroup")))
			{
				shipGroup = shipGroupAssoc.getRelatedOne("OrderItemShipGroup");
				context.shipGroupAssoc = shipGroupAssoc;
			}
			if(UtilValidate.isNotEmpty(shipGroup.getRelatedOne("PostalAddress")))
			{
				orderItemShipGroupAddress = shipGroup.getRelatedOne("PostalAddress");
				orderItemShipDate = shipGroup.estimatedShipDate;
				orderItemCarrier = shipGroup.carrierPartyId + " " + shipGroup.shipmentMethodTypeId;
				orderItemTrackingNo = shipGroup.trackingNumber;
			}
			
		}
	}
	// Fetching the carrier tracking URL
	trackingURL = "";
	trackingURLPartyContents = null;
	if(UtilValidate.isNotEmpty(shipGroup))
	{
		trackingURLPartyContents = delegator.findByAnd("PartyContent", UtilMisc.toMap("partyId",shipGroup.carrierPartyId,"partyContentTypeId", "TRACKING_URL"));
	}
	if(UtilValidate.isNotEmpty(trackingURLPartyContents))
    {
        trackingURLPartyContent = EntityUtil.getFirst(trackingURLPartyContents);
        if(UtilValidate.isNotEmpty(trackingURLPartyContent))
        {
            content = trackingURLPartyContent.getRelatedOne("Content");
            if(UtilValidate.isNotEmpty(content))
            {
                dataResource = content.getRelatedOne("DataResource");
                if(UtilValidate.isNotEmpty(dataResource))
                {
                    electronicText = dataResource.getRelatedOne("ElectronicText");
                    trackingURL = electronicText.textData;
                    if(UtilValidate.isNotEmpty(trackingURL))
                    {
                        trackingURL = FlexibleStringExpander.expandString(trackingURL,  UtilMisc.toMap("TRACKING_NUMBER":orderItemTrackingNo))
                    }
                }
            }
                
        }
        
    }
    
    context.trackingURL = trackingURL;
	if(UtilValidate.isNotEmpty(shipGroup))
	{
		context.carrierPartyId = shipGroup.carrierPartyId;
	}
	context.shipGroup = shipGroup;
	context.orderItemShipGroupAddress = orderItemShipGroupAddress;
	context.orderItemShipDate = orderItemShipDate;
	context.orderItemCarrier = orderItemCarrier;
	context.orderItemTrackingNo = orderItemTrackingNo;
	
	context.itemCancelledAmmount =itemCancelledAmmount;
	
	//get order adjustments
	context.orderAdjustments = orderReadHelper.getAdjustments();

	//get planned shipment info 
	orderShipments = orderItem.getRelated("OrderShipment");
	GenericValue orderShipment = null;
	if(UtilValidate.isNotEmpty(orderShipments))
	{
		for (GenericValue orderShip: orderShipments)
		{
			if(UtilValidate.isNotEmpty(orderShip.shipmentId))
			{
				orderShipment = orderShip;
			}
		}
	}
	
	context.orderShipment = orderShipment;
	
	//item issuances
	itemIssuances = orderItem.getRelated("ItemIssuance");
	GenericValue itemIssuance = null;
	if(UtilValidate.isNotEmpty(itemIssuances))
	{
		for (GenericValue itemIssu: itemIssuances)
		{
			if(UtilValidate.isNotEmpty(itemIssu.shipmentId))
			{
				itemIssuance = itemIssu;
			}
		}
	}
	context.itemIssuance = itemIssuance;

	//get order item attributes 
	orderItemAttributes = orderItem.getRelated("OrderItemAttribute");
	context.orderItemAttributes = orderItemAttributes;
}	





