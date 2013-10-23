package order;

import org.ofbiz.entity.util.EntityUtil;
import org.ofbiz.base.util.UtilValidate;


orderShipment = request.getAttribute("orderShipment");
if(UtilValidate.isNotEmpty(orderShipment))
{
	context.orderShipment = orderShipment;
	
	orderItemShipGroup = orderShipment.getRelatedOne("PrimaryOrderItemShipGroup");
	context.orderItemShipGroup = orderItemShipGroup;
	
	shipmentPackages = orderShipment.getRelated("ShipmentPackage");
	if(UtilValidate.isNotEmpty(shipmentPackages))
	{
		shipmentPackage = EntityUtil.getFirst(shipmentPackages);
		context.shipmentPackage = shipmentPackage;
	}
	
	shipmentPackageContents = orderShipment.getRelated("ShipmentPackageContent");
	context.shipmentPackageContents = shipmentPackageContents;
}