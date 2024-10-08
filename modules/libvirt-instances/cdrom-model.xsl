<?xml version="1.0" ?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output omit-xml-declaration="yes" indent="yes"/>
  <xsl:template match="node()|@*">
     <xsl:copy>
       <xsl:apply-templates select="node()|@*"/>
     </xsl:copy>
  </xsl:template>

  <xsl:template match="/domain/devices/disk[@device='cdrom']/target/@bus">
    <xsl:attribute name="bus">
      <xsl:value-of select="'sata'"/>
    </xsl:attribute>
  </xsl:template>

  <!-- match the root element of unknown name -->
  <xsl:template match="/*">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
      <!-- add a new element at the end -->
      <memoryBacking>
        <source type="memfd"/>
        <access mode='shared'/>
      </memoryBacking>
    </xsl:copy>
  </xsl:template>

  <!-- match the root element of unknown name -->
  <xsl:template match="filesystem">>
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
      <!-- add a new element at the end -->
      <driver type="virtiofs"/>
    </xsl:copy>
  </xsl:template>




</xsl:stylesheet>