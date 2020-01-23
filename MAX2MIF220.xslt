<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:max="http://www.umcg.nl/MAX"
	xmlns:mif="urn:hl7-org:v3/mif2"
	xmlns:fn="http://www.w3.org/2005/xpath-functions"
	exclude-result-prefixes="max fn">

	<xsl:output indent="yes" method="xml"/>
	<xsl:strip-space elements="*"/>
	
	<xsl:template match="/">
		<xsl:element name="mif:staticModel">
			<xsl:attribute name="conformanceLevel"><xsl:value-of select="//object[stereotype='StaticModel']/tag[@name='ConformanceLevel']/@value"/></xsl:attribute>
			<xsl:attribute name="schemaVersion">2.2.0</xsl:attribute>
			<xsl:attribute name="representationKind">flat</xsl:attribute>
			<xsl:attribute name="isAbstract">		
				<xsl:choose>
					<xsl:when test="//object[stereotype='StaticModel']/@isAbstract">true</xsl:when>
					<xsl:otherwise>false</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:variable name="title"><xsl:value-of select="//object[stereotype='EntryPoint']/name"/></xsl:variable>
			<xsl:attribute name="title"><xsl:value-of select="$title"/></xsl:attribute>
			<xsl:attribute name="isSerializable"><xsl:value-of select="//object[stereotype='StaticModel']/tag[@name='IsSerializable']/@value"/></xsl:attribute>

			<!-- split the name of the StaticModel package "DEFN=UV=EX=CT=000001" -->
			<xsl:variable name="comps" select="fn:tokenize(//object[stereotype='StaticModel']/name,'=')"/>
			<xsl:element name="mif:packageLocation">
				<xsl:attribute name="root"><xsl:value-of select="($comps)[1]"/></xsl:attribute>
				<xsl:attribute name="realmNamespace"><xsl:value-of select="($comps)[2]"/></xsl:attribute>
				<xsl:attribute name="artifact"><xsl:value-of select="($comps)[3]"/></xsl:attribute>
				<xsl:attribute name="domain"><xsl:value-of select="($comps)[4]"/></xsl:attribute>
				<xsl:attribute name="id"><xsl:value-of select="($comps)[5]"/></xsl:attribute>
			</xsl:element>

			<xsl:apply-templates select="//relationship[stereotype='DerivedFrom']"/>
			<xsl:apply-templates select="//object[stereotype='EntryPoint']"/>
			<xsl:apply-templates select="//object[not(type) or type='Class']"/>
			<xsl:apply-templates select="//relationship[not(type) or type='Association']"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="//object[stereotype='EntryPoint']">
		<xsl:element name="mif:entryPoint">
			<xsl:attribute name="id"><xsl:value-of select="alias"/></xsl:attribute>
			<xsl:attribute name="className"></xsl:attribute>
			<xsl:attribute name="name"><xsl:value-of select="name"/></xsl:attribute>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="//object[not(type) or type='Class']">
		<mif:containedClass>
			<xsl:element name="mif:class">
				<xsl:attribute name="name"><xsl:value-of select="name"/></xsl:attribute>
				<xsl:if test="@isAbstract">
					<xsl:attribute name="isAbstract"><xsl:value-of select="@isAbstract"/></xsl:attribute>
				</xsl:if>
				
				<xsl:for-each select="attribute">
					<xsl:element name="mif:attribute">
						<xsl:attribute name="name"><xsl:value-of select="@name"/></xsl:attribute>
						<xsl:attribute name="sortKey"><xsl:value-of select="position()"/></xsl:attribute>
						<xsl:attribute name="minimumMultiplicity">
							<xsl:choose>
								<xsl:when test="@minCard"><xsl:value-of select="@minCard"/></xsl:when>
								<xsl:otherwise>1</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>
						<xsl:attribute name="maximumMultiplicity">
							<xsl:choose>
								<xsl:when test="@maxCard"><xsl:value-of select="@maxCard"/></xsl:when>
								<xsl:otherwise>1</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>
						<xsl:attribute name="conformance">R</xsl:attribute>
						<xsl:attribute name="isMandatory">
							<xsl:choose>
								<xsl:when test="@minCard>0">true</xsl:when>
								<xsl:otherwise>false</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>
						<xsl:attribute name="isImmutable">
							<xsl:choose>
								<xsl:when test="@isReadOnly"><xsl:value-of select="@isReadOnly"/></xsl:when>
								<xsl:otherwise>false</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>
						<xsl:element name="mif:type">
							<xsl:attribute name="name"><xsl:value-of select="@type"/></xsl:attribute>
						</xsl:element>
						<xsl:if test="@value">
							<xsl:element name="mif:vocabularyDeclaration">
								<xsl:element name="mif:code">
									<xsl:attribute name="code"><xsl:value-of select="@value"/></xsl:attribute>
								</xsl:element>
							</xsl:element>
						</xsl:if>
					</xsl:element>
				</xsl:for-each>
			</xsl:element>
		</mif:containedClass>
	</xsl:template>
	
	<xsl:template match="//relationship[not(type) or type='Association']">
		<xsl:element name="mif:association">
			<xsl:element name="mif:traversableConnection">
				<xsl:attribute name="name"><xsl:value-of select="destLabel"/></xsl:attribute>
				<xsl:variable name="destCard" select="fn:tokenize(destCard, '\.\.')"/>
				<xsl:attribute name="minimumMultiplicity"><xsl:value-of select="($destCard)[1]"/></xsl:attribute>
				<xsl:attribute name="maximumMultiplicity"><xsl:value-of select="($destCard)[2]"/></xsl:attribute>
				<xsl:attribute name="isMandatory">
					<xsl:choose>
						<xsl:when test="(($destCard)[1])>0">true</xsl:when>
						<xsl:otherwise>false</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<xsl:attribute name="sortKey"><xsl:value-of select="position()"/></xsl:attribute>
				<xsl:variable name="sourceId" select="sourceId"/>
				<xsl:attribute name="participantClassName"><xsl:value-of select="//object[id=$sourceId]/name"/></xsl:attribute>
			</xsl:element>
			<xsl:element name="mif:nonTraversableConnection">
				<xsl:variable name="destId" select="destId"/>
				<xsl:attribute name="participantClassName"><xsl:value-of select="//object[id=$destId]/name"/></xsl:attribute>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="//relationship[stereotype='DerivedFrom']">
		<xsl:element name="mif:derivedFrom">
			<xsl:attribute name="staticModelDerivationId"><xsl:value-of select="position()"/></xsl:attribute>
			<!-- split the name of the StaticModel package "DEFN=UV=EX=CT=000001" -->
			<xsl:variable name="destId" select="destId"/>
			<xsl:variable name="comps" select="fn:tokenize(//object[id=$destId]/name,'=')"/>
			<xsl:element name="mif:targetStaticModel">
				<xsl:attribute name="root"><xsl:value-of select="($comps)[1]"/></xsl:attribute>
				<xsl:if test="($comps)[2]">
					<xsl:attribute name="realmNamespace"><xsl:value-of select="($comps)[2]"/></xsl:attribute>
				</xsl:if>
				<xsl:attribute name="artifact"><xsl:value-of select="($comps)[3]"/></xsl:attribute>
				<xsl:if test="($comps)[4]">
					<xsl:attribute name="domain"><xsl:value-of select="($comps)[4]"/></xsl:attribute>
				</xsl:if>
				<xsl:attribute name="id"><xsl:value-of select="($comps)[5]"/></xsl:attribute>
			</xsl:element>
		</xsl:element>
	</xsl:template>
                      
</xsl:stylesheet>