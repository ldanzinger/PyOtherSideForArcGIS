import xlrd
import csv

def convert(excel, sheet_index, output_csv):
    with xlrd.open_workbook(excel) as wb:
        sh = wb.sheet_by_index(sheet_index)
        with open(output_csv, 'w', newline='') as f:
            c = csv.writer(f)
            for r in range(sh.nrows):
                c.writerow(sh.row_values(r))
    return output_csv
