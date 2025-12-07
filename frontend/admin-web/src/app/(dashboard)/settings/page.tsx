'use client';

import {
  Box,
  Card,
  CardContent,
  Typography,
  Grid,
  TextField,
  Button,
  Switch,
  FormControlLabel,
  Divider,
  Stack,
  Avatar,
} from '@mui/material';
import { Save, PhotoCamera } from '@mui/icons-material';
import { PageHeader } from '@/components/common/page-header';

export default function SettingsPage() {
  return (
    <Box>
      <PageHeader
        title="설정"
        subtitle="시스템 설정을 관리하세요"
        breadcrumbs={[
          { label: '홈', href: '/dashboard' },
          { label: '설정' },
        ]}
      />

      <Box sx={{ display: 'flex', flexDirection: 'column', gap: 3 }}>
        {/* 첫 번째 행: 2개 */}
        <Box sx={{ display: 'grid', gridTemplateColumns: { xs: '1fr', md: '1fr 1fr' }, gap: 3 }}>
          {/* 프로필 설정 */}
          <Card>
            <CardContent>
              <Typography variant="h6" sx={{ mb: 2.5, fontWeight: 600 }}>
                프로필 설정
              </Typography>

              <Stack spacing={2}>
                <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 1 }}>
                  <Avatar
                    sx={{
                      width: 64,
                      height: 64,
                      bgcolor: 'primary.main',
                      fontSize: 28,
                    }}
                  >
                    A
                  </Avatar>
                  <Button
                    variant="outlined"
                    startIcon={<PhotoCamera />}
                    component="label"
                    size="small"
                  >
                    사진 변경
                    <input type="file" hidden accept="image/*" />
                  </Button>
                </Box>

                <TextField
                  label="이름"
                  defaultValue="관리자"
                  fullWidth
                  size="small"
                />

                <TextField
                  label="이메일"
                  type="email"
                  defaultValue="admin@doamarket.com"
                  fullWidth
                  size="small"
                />

                <TextField
                  label="전화번호"
                  defaultValue="010-1234-5678"
                  fullWidth
                  size="small"
                />

                <Box sx={{ pt: 1 }}>
                  <Button
                    variant="contained"
                    startIcon={<Save />}
                    size="small"
                  >
                    저장
                  </Button>
                </Box>
              </Stack>
            </CardContent>
          </Card>

          {/* 보안 설정 */}
          <Card>
            <CardContent>
              <Typography variant="h6" sx={{ mb: 2.5, fontWeight: 600 }}>
                보안 설정
              </Typography>

              <Stack spacing={2}>
                <TextField
                  label="현재 비밀번호"
                  type="password"
                  fullWidth
                  size="small"
                />

                <TextField
                  label="새 비밀번호"
                  type="password"
                  fullWidth
                  size="small"
                />

                <TextField
                  label="비밀번호 확인"
                  type="password"
                  fullWidth
                  size="small"
                />

                <Box sx={{ pt: 1 }}>
                  <Button
                    variant="contained"
                    startIcon={<Save />}
                    size="small"
                  >
                    비밀번호 변경
                  </Button>
                </Box>
              </Stack>
            </CardContent>
          </Card>
        </Box>

        {/* 두 번째 행: 2개 */}
        <Box sx={{ display: 'grid', gridTemplateColumns: { xs: '1fr', md: '1fr 1fr' }, gap: 3 }}>
          {/* 알림 설정 */}
          <Card>
            <CardContent>
              <Typography variant="h6" sx={{ mb: 2.5, fontWeight: 600 }}>
                알림 설정
              </Typography>

              <Stack spacing={1.5}>
                <Box>
                  <FormControlLabel
                    control={<Switch defaultChecked size="small" />}
                    label="새 주문 알림"
                  />
                </Box>
                <Divider />

                <Box>
                  <FormControlLabel
                    control={<Switch defaultChecked size="small" />}
                    label="신규 판매자 승인 요청"
                  />
                </Box>
                <Divider />

                <Box>
                  <FormControlLabel
                    control={<Switch size="small" />}
                    label="리뷰 작성 알림"
                  />
                </Box>
                <Divider />

                <Box>
                  <FormControlLabel
                    control={<Switch defaultChecked size="small" />}
                    label="정산 완료 알림"
                  />
                </Box>
                <Divider />

                <Box>
                  <FormControlLabel
                    control={<Switch size="small" />}
                    label="이메일 알림"
                  />
                </Box>
              </Stack>
            </CardContent>
          </Card>

          {/* 시스템 설정 */}
          <Card>
            <CardContent>
              <Typography variant="h6" sx={{ mb: 2.5, fontWeight: 600 }}>
                시스템 설정
              </Typography>

              <Stack spacing={2}>
                <TextField
                  label="사이트 이름"
                  defaultValue="DOA Market"
                  fullWidth
                  size="small"
                />

                <TextField
                  label="관리자 이메일"
                  type="email"
                  defaultValue="admin@doamarket.com"
                  fullWidth
                  size="small"
                />

                <TextField
                  label="고객센터 전화번호"
                  defaultValue="1588-0000"
                  fullWidth
                  size="small"
                />

                <Box>
                  <FormControlLabel
                    control={<Switch size="small" />}
                    label="사이트 유지보수 모드"
                  />
                </Box>

                <Box sx={{ pt: 1 }}>
                  <Button
                    variant="contained"
                    startIcon={<Save />}
                    size="small"
                  >
                    저장
                  </Button>
                </Box>
              </Stack>
            </CardContent>
          </Card>
        </Box>

        {/* 세 번째 행: 1개 (전체 너비) */}
        <Card>
          <CardContent>
            <Typography variant="h6" sx={{ mb: 2.5, fontWeight: 600 }}>
              정산 설정
            </Typography>

            <Box sx={{ display: 'grid', gridTemplateColumns: { xs: '1fr', sm: '1fr 1fr' }, gap: 2.5 }}>
              <TextField
                label="수수료율 (%)"
                type="number"
                defaultValue="5"
                fullWidth
                size="small"
                InputProps={{
                  inputProps: { min: 0, max: 100 },
                }}
              />

              <TextField
                label="최소 정산 금액 (₩)"
                type="number"
                defaultValue="10000"
                fullWidth
                size="small"
              />

              <TextField
                label="정산 주기 (일)"
                type="number"
                defaultValue="7"
                fullWidth
                size="small"
              />

              <TextField
                label="정산 보류 기간 (일)"
                type="number"
                defaultValue="3"
                fullWidth
                size="small"
                helperText="주문 완료 후 정산 보류 기간"
              />
            </Box>

            <Box sx={{ mt: 2.5 }}>
              <Button
                variant="contained"
                startIcon={<Save />}
                size="small"
              >
                저장
              </Button>
            </Box>
          </CardContent>
        </Card>
      </Box>
    </Box>
  );
}
