import { DataTypes, Model } from 'sequelize';
import { sequelize } from '../config/database';

class Notice extends Model {
  public id!: string;
  public title!: string;
  public content!: string;
  public category!: string;
  public status!: string;
  public views!: number;
  public isPinned!: boolean;
  public createdBy!: string;
  public readonly createdAt!: Date;
  public readonly updatedAt!: Date;
}

Notice.init(
  {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    title: {
      type: DataTypes.STRING(255),
      allowNull: false,
      comment: '공지사항 제목'
    },
    content: {
      type: DataTypes.TEXT,
      allowNull: false,
      comment: '공지사항 내용'
    },
    category: {
      type: DataTypes.ENUM('공지', '이벤트', '업데이트', '점검'),
      defaultValue: '공지',
      comment: '공지사항 카테고리'
    },
    status: {
      type: DataTypes.ENUM('draft', 'published', 'archived'),
      defaultValue: 'draft',
      comment: '공지사항 상태'
    },
    views: {
      type: DataTypes.INTEGER,
      defaultValue: 0,
      comment: '조회수'
    },
    isPinned: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
      comment: '상단 고정 여부'
    },
    createdBy: {
      type: DataTypes.UUID,
      allowNull: false,
      comment: '작성자 ID'
    },
  },
  {
    sequelize,
    tableName: 'notices',
    timestamps: true
  }
);

export default Notice;
