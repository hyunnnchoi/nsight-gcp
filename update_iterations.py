import csv

# 입력 파일과 출력 파일 경로
input_file = 'motivation_v8_trace_ps.csv'
output_file = 'motivation_v8_trace_ps_updated.csv'

# CSV 파일 읽기 및 수정
with open(input_file, 'r', newline='') as infile, open(output_file, 'w', newline='') as outfile:
    reader = csv.reader(infile)
    writer = csv.writer(outfile)
    
    # 헤더 행 처리
    header = next(reader)
    writer.writerow(header)
    
    # 데이터 행 처리
    for row in reader:
        # num_iteration는 4번째 인덱스 (5번째 컬럼)
        if len(row) > 4:
            try:
                # 현재 값에 3/5를 곱함 (1/3에서 1/5로 변경)
                current_iterations = int(row[4])
                new_iterations = int(current_iterations * 3 / 5)
                row[4] = str(new_iterations)
            except ValueError:
                # 숫자가 아닌 경우 그대로 유지
                pass
        
        writer.writerow(row)

print(f"파일이 업데이트되었습니다: {output_file}")
print("num_iteration 값들이 기존 값의 3/5로 조정되었습니다 (1/3 -> 1/5)") 