<li class="${request.getAttribute("attributeClass")!}">
  <#if pdpSelectMultiVariant?exists && pdpSelectMultiVariant?has_content && ((pdpSelectMultiVariant.toUpperCase() == "QTY") || (pdpSelectMultiVariant.toUpperCase() == "CHECKBOX")) >
      <div>
          <a href="javascript:void(0);" onClick="javascript:addMultiItems('${pdpSelectMultiVariant}','addToWishlist');" class="standardBtn addToWishlist" id="js_addToWishlist"><span>${uiLabelMap.AddToWishlistBtn}</span></a>
      </div>
  <#else>
	  <div>
	      <a href="javascript:void(0);" onClick="javascript:addItem('addToWishlist');" class="standardBtn addToWishlist <#if featureOrder?exists && featureOrder?size gt 0>inactiveAddToWishlist</#if>" id="js_addToWishlist"><span>${uiLabelMap.AddToWishlistBtn}</span></a>
	  </div>
  </#if>
</li>
