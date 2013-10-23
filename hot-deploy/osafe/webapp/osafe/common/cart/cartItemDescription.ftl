<li class="${request.getAttribute("attributeClass")!}">
  <div>
    <label>${uiLabelMap.CartItemDescriptionCaption}</label>
    <span>
	  <ul class="displayList productFeature">
		<#if productFeatureAndAppls?has_content>
          <#list productFeatureAndAppls as productFeatureAndAppl>
            <li class="string productFeature">
              <#assign productFeatureTypeLabel = ""/>
    	      <#if productFeatureTypesMap?has_content>
		        <#assign productFeatureTypeLabel = productFeatureTypesMap.get(productFeatureAndAppl.productFeatureTypeId)!"" />
		      </#if>
		      <div>
		        <span>${productFeatureTypeLabel!}:${productFeatureAndAppl.description!}</span>
		      </div>
		    </li>
		  </#list>
		</#if>
      </ul>
    </span>
  </div>
</li>   
