import os
from fpdf import FPDF

class PDF(FPDF):
    def header(self):
        self.set_font('helvetica', 'B', 15)
        self.cell(0, 10, 'Plant Disease App - Full Documentation', border=False, new_x="LMARGIN", new_y="NEXT", align='C')
        self.ln(10)

    def footer(self):
        self.set_y(-15)
        self.set_font('helvetica', 'I', 8)
        self.cell(0, 10, f'Page {self.page_no()}', 0, 0, 'C')

def create_pdf(input_md_path, output_pdf_path):
    pdf = PDF()
    pdf.add_page()
    pdf.set_font('helvetica', '', 11)
    
    with open(input_md_path, 'r', encoding='utf-8') as file:
        lines = file.readlines()
        
    for line in lines:
        line = line.strip()
        if not line:
            pdf.ln(5)
            continue
            
        if line.startswith('## '):
            pdf.set_font('helvetica', 'B', 14)
            pdf.cell(0, 10, line.replace('## ', ''), new_x="LMARGIN", new_y="NEXT")
            pdf.set_font('helvetica', '', 11)
        elif line.startswith('### '):
            pdf.ln(3)
            pdf.set_font('helvetica', 'B', 12)
            pdf.cell(0, 10, line.replace('### ', ''), new_x="LMARGIN", new_y="NEXT")
            pdf.set_font('helvetica', '', 11)
        elif line.startswith('# '):
            pdf.set_font('helvetica', 'B', 16)
            pdf.cell(0, 12, line.replace('# ', ''), new_x="LMARGIN", new_y="NEXT")
            pdf.set_font('helvetica', '', 11)
        else:
            # simple text
            clean_line = line.replace('**', '').replace('__', '')
            pdf.multi_cell(0, 8, clean_line)

    pdf.output(output_pdf_path)
    print(f"Successfully created PDF: {output_pdf_path}")

if __name__ == "__main__":
    create_pdf('Plant_Disease_App_Documentation.md', 'Plant_Disease_App_Documentation.pdf')
