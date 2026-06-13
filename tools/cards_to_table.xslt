<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="html" encoding="UTF-8" indent="yes"/>

  <xsl:template match="/cards">
    <html>
      <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <title>Molekuly - Cards Database</title>
        <style>
          body{font-family:Arial,Helvetica,sans-serif;padding:16px;background:#fafafa;color:#333;}
          table{border-collapse:collapse;width:100%;margin-bottom:32px;background:#fff;box-shadow:0 1px 3px rgba(0,0,0,0.1);}
          th,td{border:1px solid #ddd;padding:8px;text-align:left;vertical-align:middle}
          th{background:#2c3e50;color:#fff;}
          h1,h2{font-weight:600;}
          h1{color:#2c3e50;border-bottom:2px solid #2c3e50;padding-bottom:8px;}
          h2{margin-top:24px;color:#34495e;}
          .filters{margin-bottom:12px}
          .filters select{padding:6px;margin-right:8px;margin-bottom:8px;border:1px solid #ccc;border-radius:4px;}
          img.preview { max-width: 60px; max-height: 60px; border: 1px solid #ccc; object-fit: contain; }
          .color-preview { display: inline-block; width: 20px; height: 20px; border: 1px solid #111; border-radius: 4px; vertical-align: middle; margin-right: 8px; }
          .badge { padding: 4px 8px; border-radius: 4px; font-size: 0.9em; font-weight: bold; background: #e0e0e0; }
        </style>
        
        <script>
          document.addEventListener('DOMContentLoaded', function(){
            // Generic dynamic filter engine based on col- prefix classes
            document.querySelectorAll('table.filterable').forEach(function(table){
              var rows = Array.from(table.querySelectorAll('tr')).slice(1);
              var filtersDiv = table.previousElementSibling &amp;&amp; table.previousElementSibling.classList.contains('filters') ? table.previousElementSibling : null;
              if(!filtersDiv) return;
              var colClasses = new Set();
              rows.forEach(function(r){ r.querySelectorAll('td').forEach(function(td){ td.classList.forEach(function(c){ if(c.indexOf('col-')===0) colClasses.add(c); }); }); });
              colClasses.forEach(function(colClass){
                var select = document.createElement('select');
                select.dataset.col = colClass;
                var opt = document.createElement('option'); opt.value=''; opt.text='All '+colClass.replace('col-',''); select.appendChild(opt);
                var values = new Set();
                table.querySelectorAll('td.'+colClass).forEach(function(td){ values.add(td.textContent.trim()); });
                Array.from(values).sort().forEach(function(v){ var o=document.createElement('option'); o.value=v; o.text=v; select.appendChild(o); });
                select.addEventListener('change', function(){
                  var selVals = {};
                  filtersDiv.querySelectorAll('select').forEach(function(s){ if(s.value) selVals[s.dataset.col]=s.value; });
                  rows.forEach(function(row){
                    var show = true;
                    Object.keys(selVals).forEach(function(cc){
                      var cell = row.querySelector('td.'+cc);
                      var val = cell?cell.textContent.trim():'';
                      if(val !== selVals[cc]) show = false;
                    });
                    row.style.display = show ? '' : 'none';
                  });
                });
                filtersDiv.appendChild(select);
              });
            });
          });
        </script>
      </head>
      <body>
        <h1>Molekuly - Cards Database</h1>

        <h2>Atomy (Prvky a suroviny)</h2>
        <div class="filters"></div>
        <table class="filterable">
          <tr>
            <th>ID</th><th>Symbol</th><th>Název</th><th>Počet v balíčku</th><th>Hmotnost (Cena)</th><th>Valenční elektrony</th><th>Barva karty</th>
          </tr>
          <xsl:for-each select="atoms/atom">
            <tr>
              <td><xsl:value-of select="@id"/></td>
              <td style="font-weight:bold;"><xsl:value-of select="symbol"/></td>
              <td><xsl:value-of select="name"/></td>
              <td>
                <xsl:choose>
                  <xsl:when test="@count"><xsl:value-of select="@count"/></xsl:when>
                  <xsl:otherwise>1</xsl:otherwise>
                </xsl:choose>
              </td>
              <td class="col-weight"><xsl:value-of select="weight"/></td>
              <td class="col-valence"><span class="badge"><xsl:value-of select="valence_electrons"/> e-</span></td>
              <td>
                <span class="color-preview" style="background-color: {color};"></span>
                <code><xsl:value-of select="color"/></code>
              </td>
            </tr>
          </xsl:for-each>
        </table>

        <h2>Molekuly (Recepty a kontrakty)</h2>
        <div class="filters"></div>
        <table class="filterable">
          <tr>
            <th>ID</th><th>Název</th><th>Vzorec</th><th>Počet v balíčku</th><th>Bodová hodnota</th><th>Náhled strukturního vzorce</th><th>Lore (Zajímavost)</th>
          </tr>
          <xsl:for-each select="molecules/molecule">
            <tr>
              <td><xsl:value-of select="@id"/></td>
              <td style="font-weight:bold;"><xsl:value-of select="title"/></td>
              <td class="col-formula" style="font-family:monospace; font-size:1.1em; color:#c0392b;"><xsl:value-of select="formula"/></td>
              <td>
                <xsl:choose>
                  <xsl:when test="@count"><xsl:value-of select="@count"/></xsl:when>
                  <xsl:otherwise>1</xsl:otherwise>
                </xsl:choose>
              </td>
              <td class="col-points" style="font-weight:bold; color:#27ae60;"><xsl:value-of select="points"/> pts</td>
              <td>
                <xsl:if test="string-length(image) &gt; 0">
                  <img class="preview">
                    <xsl:attribute name="src"><xsl:value-of select="image"/></xsl:attribute>
                  </img>
                </xsl:if>
              </td>
              <td style="font-style:italic; font-size:0.95em; color:#555;"><xsl:value-of select="lore"/></td>
            </tr>
          </xsl:for-each>
        </table>

      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>