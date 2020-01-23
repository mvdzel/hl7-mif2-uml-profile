<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:max="http://www.umcg.nl/MAX"
	xmlns:mif="urn:hl7-org:v3/mif2"
	exclude-result-prefixes="max">

	<xsl:output indent="yes" method="xml"/>
	<xsl:strip-space elements="*"/>
	<xsl:variable name="rootPackageName"><xsl:value-of select="concat(mif:staticModel/mif:packageLocation/@root,'=',mif:staticModel/mif:packageLocation/@realmNamespace,'=',mif:staticModel/mif:packageLocation/@artifact,'=',mif:staticModel/mif:packageLocation/@domain,'=',mif:staticModel/mif:packageLocation/@id)"/></xsl:variable>
	<xsl:variable name="rootPackageId">P<xsl:value-of select="$rootPackageName"/></xsl:variable>
	
	<xsl:template match="/">
		<max:model>
			<xsl:apply-templates select="mif:staticModel"/>
		</max:model>
	</xsl:template>

<!-- Object Templates -->
	
	<xsl:template match="mif:staticModel">
		<objects>
			<!-- Package and PackgeRefs -->
			<xsl:apply-templates select="mif:packageLocation" mode="object"/>
			<xsl:apply-templates select="mif:derivedFrom/mif:targetStaticModel" mode="object"/>
			<xsl:apply-templates select="mif:importedDatatypeModelPackage" mode="object"/>
			<xsl:apply-templates select="mif:importedVocabularyModelPackage" mode="object"/>
			<xsl:apply-templates select="mif:importedCommonModelElementPackage" mode="object"/>
		
			<!-- Order matters for MAX Importer, so first handle objects that have no parent in this package -->
			<xsl:apply-templates select="mif:entryPoint" mode="object"/>
			<xsl:apply-templates select="mif:containedClass/mif:class[mif:childClass]" mode="object"/>
			<xsl:apply-templates select="mif:containedClass/mif:class[not(mif:childClass)]" mode="object"/>
			<xsl:apply-templates select="mif:containedClass/mif:commonModelElementRef" mode="object"/>
		</objects>
		<relationships>
			<xsl:apply-templates select="/mif:staticModel/mif:derivedFrom" mode="relationship"/>
			<xsl:apply-templates select="mif:importedDatatypeModelPackage" mode="relationship"/>
			<xsl:apply-templates select="mif:importedVocabularyModelPackage" mode="relationship"/>
			<xsl:apply-templates select="mif:importedCommonModelElementPackage" mode="relationship"/>
			<xsl:apply-templates select="mif:association" mode="relationship"/>
			<xsl:apply-templates select="mif:containedClass" mode="relationship"/>
			<xsl:apply-templates select="mif:entryPoint" mode="relationship"/>
		</relationships>
	</xsl:template>
	
	<!-- Root StaticModel Package -->
	<xsl:template match="mif:packageLocation" mode="object">
		<xsl:element name="object">
			<id><xsl:value-of select="$rootPackageId"/></id>
			<name><xsl:value-of select="$rootPackageName"/></name>
			<stereotype>StaticModel</stereotype>
			<type>Package</type>
		</xsl:element>
	</xsl:template>
	
	<!-- Derived PackageRef -->	
	<xsl:template match="mif:derivedFrom/mif:targetStaticModel" mode="object">
		<xsl:element name="object">
			<xsl:variable name="name" select="concat(@root,'=',@realmNamespace,'=',@artifact,'=',@domain,'=',@id,@version)"/>
			<id>P<xsl:value-of select="$name"/></id>
			<name><xsl:value-of select="$name"/></name>
			<stereotype>StaticModelRef</stereotype>
			<type>Package</type>
		</xsl:element>
	</xsl:template>

	<!-- DatatypeModel <import> -->	
	<xsl:template match="mif:importedDatatypeModelPackage" mode="object">
		<xsl:element name="object">
			<xsl:variable name="name" select="concat(@root,'=',@realmNamespace,'=',@artifact,'=',@version)"/>
			<id>P<xsl:value-of select="$name"/></id>
			<name><xsl:value-of select="$name"/></name>
			<stereotype>StaticModelRef</stereotype>
			<type>Package</type>
		</xsl:element>
	</xsl:template>
	
	<!-- VocabModel <import> -->	
	<xsl:template match="mif:importedVocabularyModelPackage" mode="object">
		<xsl:element name="object">
			<xsl:variable name="name" select="concat(@root,'=',@realmNamespace,'=',@artifact,'=',@version)"/>
			<id>P<xsl:value-of select="$name"/></id>
			<name><xsl:value-of select="$name"/></name>
			<stereotype>StaticModelRef</stereotype>
			<type>Package</type>
		</xsl:element>
	</xsl:template>

	<!-- CMET Model <import> -->	
	<xsl:template match="mif:importedCommonModelElementPackage" mode="object">
		<xsl:element name="object">
			<xsl:variable name="name" select="concat(@root,'=',@realmNamespace,'=',@artifact,'=',@version)"/>
			<id>P<xsl:value-of select="$name"/></id>
			<name><xsl:value-of select="$name"/></name>
			<stereotype>StaticModelRef</stereotype>
			<type>Package</type>
		</xsl:element>
	</xsl:template>	
		
	<!-- CMET's -->
	<xsl:template match="mif:containedClass/mif:commonModelElementRef" mode="object">
		<xsl:element name="object">
			<xsl:variable name="name" select="@name"/>
			<id>C<xsl:value-of select="$name"/></id>
			<name><xsl:value-of select="$name"/></name>
			<stereotype>CommonModelElementRef</stereotype>
			<type>Interface</type>
			<xsl:choose>
				<xsl:when test="//mif:containedClass/mif:class[mif:childClass/@name=$name and not(mif:attribute)]">
					<parentId>C<xsl:value-of select="//mif:containedClass/mif:class[mif:childClass/@name=$name]/@name"/></parentId>
				</xsl:when>
				<xsl:otherwise>
					<parentId><xsl:value-of select="$rootPackageId"/></parentId>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>
	
	<!-- Do Choices -->
	<xsl:template match="mif:containedClass/mif:class[not(mif:attribute)]" mode="object">
		<xsl:element name="object">
			<xsl:attribute name="isAbstract"><xsl:value-of select="@isAbstract"/></xsl:attribute>
			<xsl:variable name="name" select="@name"/>
			<id>C<xsl:value-of select="$name"/></id>
			<name><xsl:value-of select="$name"/></name>
			<stereotype>Choice</stereotype>
			<type>Class</type>
			<xsl:choose>
				<xsl:when test="//mif:containedClass/mif:class[mif:childClass/@name=$name and not(mif:attribute)]">
					<parentId>C<xsl:value-of select="//mif:containedClass/mif:class[mif:childClass/@name=$name]/@name"/></parentId>
				</xsl:when>
				<xsl:otherwise>
					<parentId><xsl:value-of select="$rootPackageId"/></parentId>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>
	
	<!-- Do regular Classes -->
	<xsl:template match="mif:containedClass/mif:class[mif:attribute]" mode="object">
		<xsl:element name="object">
			<xsl:attribute name="isAbstract"><xsl:value-of select="@isAbstract"/></xsl:attribute>
			<xsl:variable name="name" select="@name"/>
			<id>C<xsl:value-of select="$name"/></id>
			<name><xsl:value-of select="$name"/></name>
			<notes><xsl:value-of select="mif:annotations/mif:documentation//mif:text//text()"/></notes>
			<type>Class</type>
			<xsl:choose>
				<xsl:when test="//mif:containedClass/mif:class[mif:childClass/@name=$name and not(mif:attribute)]">
					<parentId>C<xsl:value-of select="//mif:containedClass/mif:class[mif:childClass/@name=$name]/@name"/></parentId>
				</xsl:when>
				<xsl:otherwise>
					<parentId><xsl:value-of select="$rootPackageId"/></parentId>
				</xsl:otherwise>
			</xsl:choose>
			
			<xsl:for-each select="mif:attribute">
				<xsl:element name="attribute">
					<xsl:attribute name="name"><xsl:value-of select="@name"/></xsl:attribute>
					<xsl:if test="mif:businessName">
						<xsl:attribute name="alias"><xsl:value-of select="mif:businessName/@name"/></xsl:attribute>
					</xsl:if>
					<xsl:if test="mif:vocabulary/mif:valueSet">
						<xsl:attribute name="value"><xsl:value-of select="mif:vocabulary/mif:valueSet/@rootCode"/></xsl:attribute>
					</xsl:if>
					<xsl:attribute name="minCard"><xsl:value-of select="@minimumMultiplicity"/></xsl:attribute>
					<xsl:attribute name="maxCard"><xsl:value-of select="@maximumMultiplicity"/></xsl:attribute>
					<xsl:attribute name="type">
						<xsl:value-of select="mif:type/@name"/>
						<xsl:if test="mif:type/mif:argumentDatatype">&lt;<xsl:value-of select="mif:type/mif:argumentDatatype/@name"/>&gt;</xsl:if>
					</xsl:attribute>
					<xsl:if test="@isImmutable">
						<xsl:attribute name="isReadOnly"><xsl:value-of select="@isImmutable"/></xsl:attribute>
					</xsl:if>
					<xsl:value-of select="mif:annotations/mif:documentation//mif:text//text()"/>
				</xsl:element>
			</xsl:for-each>
		</xsl:element>
	</xsl:template>
	
	<!-- Do entrypoints -->
	<xsl:template match="mif:entryPoint" mode="object">
		<xsl:element name="object">
			<xsl:variable name="name" select="@name"/>
			<id>E<xsl:value-of select="$name"/></id>
			<name><xsl:value-of select="$name"/></name>
			<xsl:if test="@id">
				<alias><xsl:value-of select="@id"/></alias>
			</xsl:if>
			<notes><xsl:value-of select="mif:annotations/mif:documentation//mif:text/text()"/></notes>
			<stereotype>EntryPoint</stereotype>
			<type>Interface</type>
			<parentId><xsl:value-of select="$rootPackageId"/></parentId>
		</xsl:element>
	</xsl:template>
	
<!-- Relationship Templates -->

	<!-- Do general traversable associations -->
	<xsl:template match="mif:association[not(mif:nonTraversableConnection)]" mode="relationship">
		<xsl:element name="relationship">
			<sourceId>C<xsl:value-of select="mif:traversableConnection[1]/@participantClassName"/></sourceId>
			<sourceLabel><xsl:value-of select="mif:traversableConnection[1]/@name"/></sourceLabel>
			<sourceCard><xsl:value-of select="mif:traversableConnection[1]/@minimumMultiplicity"/>..<xsl:value-of select="mif:traversableConnection[1]/@maximumMultiplicity"/></sourceCard>
			<destId>C<xsl:value-of select="mif:traversableConnection[2]/@participantClassName"/></destId>
			<destLabel><xsl:value-of select="mif:traversableConnection[2]/@name"/></destLabel>
			<destCard><xsl:value-of select="mif:traversableConnection[2]/@minimumMultiplicity"/>..<xsl:value-of select="mif:traversableConnection[2]/@maximumMultiplicity"/></destCard>
			<notes><xsl:value-of select="mif:annotations/mif:documentation//mif:text//text()"/></notes>
		</xsl:element>
	</xsl:template>
	
	<!-- Do general non-traversable associations -->
	<xsl:template match="mif:association[mif:nonTraversableConnection]"  mode="relationship">
		<xsl:element name="relationship">
			<sourceId>C<xsl:value-of select="mif:traversableConnection[1]/@participantClassName"/></sourceId>
			<sourceLabel><xsl:value-of select="mif:traversableConnection[1]/@name"/></sourceLabel>
			<sourceCard><xsl:value-of select="mif:traversableConnection[1]/@minimumMultiplicity"/>..<xsl:value-of select="mif:traversableConnection[1]/@maximumMultiplicity"/></sourceCard>
			<destId>C<xsl:value-of select="mif:nonTraversableConnection/@participantClassName"/></destId>
			<destLabel><xsl:value-of select="mif:nonTraversableConnection/mif:derivedFrom/@associationEndName"/></destLabel>
			<notes><xsl:value-of select="mif:annotations/mif:documentation//mif:text//text()"/></notes>
		</xsl:element>
	</xsl:template>
	
	<!-- Do generalizations via parentClass -->
	<xsl:template match="mif:containedClass/mif:class[mif:parentClass]" mode="relationship">
		<xsl:element name="relationship">
			<sourceId>C<xsl:value-of select="@name"/></sourceId>
			<destId>C<xsl:value-of select="mif:parentClass/@name"/></destId>
			<type>Generalization</type>
		</xsl:element>
	</xsl:template>
	
	<!-- Do entrypoint relationships -->
	<xsl:template match="mif:entryPoint" mode="relationship">
		<xsl:element name="relationship">
			<sourceId>E<xsl:value-of select="@name"/></sourceId>
			<destId>C<xsl:value-of select="@className"/></destId>
			<type>DirectedAssociation</type>
		</xsl:element>
	</xsl:template>
	
	<!-- Derived PackageRef relationship -->	
	<xsl:template match="/mif:staticModel/mif:derivedFrom" mode="relationship">
		<xsl:element name="relationship">
			<label><xsl:value-of select="concat('staticModelDerivationId=',@staticModelDerivationId)"/></label>
			<xsl:variable name="name" select="concat(mif:targetStaticModel/@root,'=',mif:targetStaticModel/@realmNamespace,'=',mif:targetStaticModel/@artifact,'=',mif:targetStaticModel/@domain,'=',mif:targetStaticModel/@id,mif:targetStaticModel/@version)"/>
			<sourceId>P<xsl:value-of select="$name"/></sourceId>
			<destId><xsl:value-of select="$rootPackageId"/></destId>
			<stereotype>DerivedFrom</stereotype>
			<type>Dependency</type>
		</xsl:element>
	</xsl:template>
	
	<!-- DatatypeModel <import> -->	
	<xsl:template match="mif:importedDatatypeModelPackage" mode="relationship">
		<xsl:element name="relationship">
			<xsl:variable name="name" select="concat(@root,'=',@realmNamespace,'=',@artifact,'=',@version)"/>
			<sourceId>P<xsl:value-of select="$name"/></sourceId>
			<destId><xsl:value-of select="$rootPackageId"/></destId>
			<stereotype>import</stereotype>
			<type>Dependency</type>
		</xsl:element>
	</xsl:template>
	
	<!-- VocabModel <import> -->	
	<xsl:template match="mif:importedVocabularyModelPackage" mode="relationship">
		<xsl:element name="relationship">
			<xsl:variable name="name" select="concat(@root,'=',@realmNamespace,'=',@artifact,'=',@version)"/>
			<sourceId>P<xsl:value-of select="$name"/></sourceId>
			<destId><xsl:value-of select="$rootPackageId"/></destId>
			<stereotype>import</stereotype>
			<type>Dependency</type>
		</xsl:element>
	</xsl:template>

	<!-- CMET Model <import> -->	
	<xsl:template match="mif:importedCommonModelElementPackage" mode="relationship">
		<xsl:element name="relationship">
			<xsl:variable name="name" select="concat(@root,'=',@realmNamespace,'=',@artifact,'=',@version)"/>
			<sourceId>P<xsl:value-of select="$name"/></sourceId>
			<destId><xsl:value-of select="$rootPackageId"/></destId>
			<stereotype>import</stereotype>
			<type>Dependency</type>
		</xsl:element>
	</xsl:template>	
	
</xsl:stylesheet>