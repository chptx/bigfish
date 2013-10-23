<li class="${request.getAttribute("attributeClass")!}">
 <div>
      <#if trackingNumber?exists && trackingNumber?has_content>
	      <label>${uiLabelMap.TrackingNumberCaption}</label>
          <#if trackingURL?has_content>
            <a href="JavaScript:newPopupWindow('${trackingURL!""}');">${trackingNumber!}</a>
          <#else>
           <span>${trackingNumber!}</span>
          </#if>
      </#if>			      
 </div>
</li>