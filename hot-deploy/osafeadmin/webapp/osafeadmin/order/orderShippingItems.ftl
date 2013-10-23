<div class="boxBody">
    <div class="heading">${orderShippingItemInfoHeading!}</div>
    <table class="osafe">
        <tr class="heading">
            <th class="idCol firstCol">${uiLabelMap.ItemNoLabel}</th>
            <th class="nameCol">${uiLabelMap.ProductNameLabel}</th>
            <th class="dollarCol">${uiLabelMap.ItemPriceLabel}</th>
            <th class="qtyCol lastCol">${uiLabelMap.QtyShippedLabel}</th>
        </tr>
        <#assign currencyUomId = orderReadHelper.getCurrency()>
        <#assign resultList = shipmentPackageContents?if_exists/>
        <#if resultList?exists && resultList?has_content>
            <#assign rowClass = "1"/>
            <#list resultList as shipmentPackageContent>
                <tr class="dataRow <#if rowClass?if_exists == "2">even<#else>odd</#if>">
                    <#assign itemProduct = shipmentPackageContent.getRelatedOne("SubProduct")!/>
                    <#assign itemNo = itemProduct.internalName! />
                    <#assign productName = itemProduct.productName!"" />
                    <#if itemProduct.isVariant?if_exists?upper_case == "Y">
                       	<#assign virtualProduct = Static["org.ofbiz.product.product.ProductWorker"].getParentProduct(itemProduct.productId, delegator)?if_exists>
                    </#if>
                    <#if productName == "">
                        <#assign productName = Static['org.ofbiz.product.product.ProductContentWrapper'].getProductContentAsText(virtualProduct, 'PRODUCT_NAME', request)?if_exists>
                    </#if>
                    
                    <#assign productDefaultPrice = Static["com.osafe.util.OsafeAdminUtil"].getProductPrice(request, itemProduct.productId, "DEFAULT_PRICE")!/>
                    <#if !productDefaultPrice?has_content>
                        <#assign productDefaultPrice = Static["com.osafe.util.OsafeAdminUtil"].getProductPrice(request, virtualProduct.productId, "DEFAULT_PRICE")!/>
                    </#if>
                    
                    <td class="idCol firstCol <#if !shipmentPackageContent_has_next?if_exists>lastRow</#if>">${itemNo!}</td>
                    <td class="nameCol <#if !shipmentPackageContent_has_next?if_exists>lastRow</#if>">${productName!}</td>
                    <td class="dollarCol <#if !shipmentPackageContent_has_next?if_exists>lastRow</#if>"><@ofbizCurrency amount=productDefaultPrice.price rounding=globalContext.currencyRounding isoCode=currencyUomId/></td>
                    <td class="qtyCol lastCol <#if !shipmentPackageContent_has_next?if_exists>lastRow</#if>">${shipmentPackageContent.quantity!}</td>
                </tr>
                <#if rowClass == "2">
                    <#assign rowClass = "1">
                <#else>
                    <#assign rowClass = "2">
                </#if>
            </#list>
        <#else>
            ${screens.render("component://osafeadmin/widget/CommonScreens.xml#ListNoDataResult")}
        </#if>
    </table>
</div>

