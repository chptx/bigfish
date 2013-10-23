<form method="post" name="${detailFormName!""}" <#if detailFormId?exists>id="${detailFormId!}"</#if>>
${screens.render("component://osafeadmin/widget/CommonScreens.xml#commonFormHiddenFields")}
<#if generalInfoBoxHeading?exists && generalInfoBoxHeading?has_content>
    <div class="displayBox generalInfo">
        <div class="header">
        	<h2>${generalInfoBoxHeading!}</h2>
        	<#if stores?has_content && (stores.size() > 1)>
        	  <#if (showProductStoreInfo?has_content) && (showProductStoreInfo == 'Y')>
                <div class="productStoreInfo">
                    ${uiLabelMap.ProductStoreInfoCaption}
                    <#if context.productStoreName?has_content>
                        ${context.productStoreName}
                    </#if>
                </div>
              </#if>
            </#if>
        </div>
        <div class="boxBody">
            ${sections.render('generalInfoBoxBody')!}
        </div>
    </div>
</#if>

<#if orderShipments?exists && orderShipments?has_content>
  <#list orderShipments as orderShipment >
  ${setRequestAttribute("orderShipment",orderShipment)}
    <div class="displayListBox generalInfo">
	    <div class="header"><h2>${orderShippingDetailBoxHeading!}# ${orderShipment.shipmentId!}</h2></div>
	    ${sections.render('orderShippingDetailsInfoBoxBody')!}
	    ${sections.render('orderShippedToDetailBoxBody')!}
        ${sections.render('orderShippingPackageBoxBody')!}
        ${sections.render('orderShippingItemBoxBody')!}
    </div>
  </#list>
</#if>

<div class="displayBox footerInfo">
    <div>
          ${sections.render('footerBoxBody')}
    </div>
    <div class="infoDetailIcon">
      ${sections.render('commonDetailLinkButton')!}
    </div>
</div>
</form>
${sections.render('commonFormJS')?if_exists}
${sections.render('tooltipBody')?if_exists}